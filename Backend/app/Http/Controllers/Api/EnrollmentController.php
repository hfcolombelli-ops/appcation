<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Answer;
use App\Models\Certificate;
use App\Models\Enrollment;
use App\Models\Question;
use App\Models\Training;
use App\Models\TrainingBlock;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class EnrollmentController extends Controller
{
    public function join(Request $request)
    {
        $data = $request->validate([
            'join_hash' => ['required', 'string', 'max:64'],
        ]);

        $data['join_hash'] = Str::lower(trim($data['join_hash']));

        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Somente treinandos entram por código.'], 403);
        }

        $training = Training::query()
            ->where('join_hash', $data['join_hash'])
            ->with('institution:id,name')
            ->firstOrFail();

        $enrollment = Enrollment::query()->firstOrCreate(
            [
                'training_id' => $training->id,
                'user_id' => $request->user()->id,
            ],
            [
                'status' => 'waiting',
                'joined_at' => now(),
            ]
        );

        $enrollment->load(['training' => function ($q) {
            $q->with('institution:id,name');
        }]);

        return response()->json([
            'enrollment' => $enrollment,
            'training' => $training,
        ]);
    }

    public function mine(Request $request)
    {
        $rows = Enrollment::query()
            ->where('user_id', $request->user()->id)
            ->with(['training' => function ($q) {
                $q->with('institution:id,name');
            }])
            ->latest()
            ->limit(30)
            ->get();

        return response()->json($rows);
    }

    public function show(Request $request, string $id)
    {
        $enrollment = Enrollment::query()->with(['training' => function ($q) {
            $q->with('institution:id,name');
        }])->findOrFail($id);

        if ((int) $enrollment->user_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        return response()->json($enrollment);
    }

    public function forTraining(Request $request, string $trainingId)
    {
        $training = Training::findOrFail($trainingId);

        if ((int) $training->instructor_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Somente o instrutor deste treinamento pode listar inscrições.'], 403);
        }

        $questionCount = Question::query()
            ->whereHas('trainingBlock', fn ($q) => $q->where('training_id', $training->id))
            ->count();

        $blocks = TrainingBlock::query()
            ->where('training_id', $training->id)
            ->orderBy('sort_order')
            ->get(['id', 'title', 'sort_order', 'is_released']);

        $questionsByBlock = Question::query()
            ->whereIn('training_block_id', $blocks->pluck('id'))
            ->get(['id', 'training_block_id'])
            ->groupBy('training_block_id');

        $enrollmentRows = Enrollment::query()
            ->where('training_id', $training->id)
            ->with('user:id,name,email')
            ->orderBy('joined_at')
            ->get();

        $eids = $enrollmentRows->pluck('id');

        $certsByEnrollment = Certificate::query()
            ->whereIn('enrollment_id', $eids)
            ->get(['id', 'enrollment_id', 'certificate_code', 'issued_at', 'expires_at', 'score'])
            ->keyBy('enrollment_id');

        $answersByEnrollment = Answer::query()
            ->whereIn('enrollment_id', $eids)
            ->get()
            ->groupBy('enrollment_id');

        $enrollments = $enrollmentRows->map(function (Enrollment $e) use ($questionCount, $blocks, $questionsByBlock, $answersByEnrollment, $certsByEnrollment) {
            $answered = Answer::query()
                ->where('enrollment_id', $e->id)
                ->whereNotNull('question_option_id')
                ->count();

            $byQuestion = $answersByEnrollment->get($e->id, collect())->keyBy('question_id');

            $blockMetrics = [];
            foreach ($blocks as $block) {
                $qids = $questionsByBlock->get($block->id, collect())->pluck('id');
                $total = $qids->count();
                if ($total === 0) {
                    continue;
                }

                $correct = 0;
                $answeredInBlock = 0;
                foreach ($qids as $qid) {
                    $a = $byQuestion->get($qid);
                    if ($a === null) {
                        continue;
                    }
                    $answeredInBlock++;
                    if ($a->is_correct === true) {
                        $correct++;
                    }
                }

                $wrongInBlock = $answeredInBlock - $correct;
                $unanswered = $total - $answeredInBlock;
                $accuracy = round(100 * $correct / $total, 1);
                $belowHalf = $correct < ($total / 2);

                $blockMetrics[] = [
                    'training_block_id' => $block->id,
                    'title' => $block->title,
                    'sort_order' => (int) $block->sort_order,
                    'is_released' => (bool) $block->is_released,
                    'question_count' => $total,
                    'correct_count' => $correct,
                    'wrong_count' => $wrongInBlock,
                    'unanswered_count' => $unanswered,
                    'accuracy_percent' => $accuracy,
                    'below_50_percent' => $belowHalf,
                ];
            }

            $cert = $certsByEnrollment->get($e->id);

            return [
                'enrollment' => $e,
                'user' => $e->user,
                'answered_count' => $answered,
                'question_count' => $questionCount,
                'block_metrics' => $blockMetrics,
                'certificate' => $cert === null ? null : [
                    'id' => $cert->id,
                    'certificate_code' => $cert->certificate_code,
                    'issued_at' => $cert->issued_at,
                    'expires_at' => $cert->expires_at,
                    'score' => $cert->score,
                ],
            ];
        });

        $training->load('institution:id,name');

        return response()->json([
            'training' => array_merge($training->toArray(), [
                'session_paused' => $training->last_command === 'pause',
            ]),
            'training_blocks' => $blocks,
            'participants' => $enrollments,
        ]);
    }
}
