<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Answer;
use App\Models\Enrollment;
use App\Models\Question;
use App\Models\Training;
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

        $enrollments = Enrollment::query()
            ->where('training_id', $training->id)
            ->with('user:id,name,email')
            ->orderBy('joined_at')
            ->get()
            ->map(function (Enrollment $e) use ($questionCount) {
                $answered = Answer::query()
                    ->where('enrollment_id', $e->id)
                    ->whereNotNull('question_option_id')
                    ->count();

                return [
                    'enrollment' => $e,
                    'user' => $e->user,
                    'answered_count' => $answered,
                    'question_count' => $questionCount,
                ];
            });

        return response()->json([
            'training' => $training->load('institution:id,name'),
            'participants' => $enrollments,
        ]);
    }
}
