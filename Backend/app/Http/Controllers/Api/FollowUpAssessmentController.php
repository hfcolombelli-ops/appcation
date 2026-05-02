<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EnrollmentFollowUp;
use App\Support\FollowUpDefinition;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class FollowUpAssessmentController extends Controller
{
    public function index(Request $request)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Disponível apenas para treinandos.'], 403);
        }

        $rows = EnrollmentFollowUp::query()
            ->whereHas('enrollment', fn ($q) => $q->where('user_id', $request->user()->id))
            ->with(['enrollment.training:id,title,metadata'])
            ->orderBy('due_at')
            ->limit(120)
            ->get();

        return response()->json($rows);
    }

    public function show(Request $request, string $id)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Disponível apenas para treinandos.'], 403);
        }

        $row = EnrollmentFollowUp::query()
            ->whereKey($id)
            ->with(['enrollment.training'])
            ->firstOrFail();

        if ((int) $row->enrollment->user_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        $training = $row->enrollment->training;
        $questions = FollowUpDefinition::questionsForTraining($training);

        return response()->json([
            'follow_up' => $row,
            'questions' => $questions,
            'can_submit' => $row->status === 'pending' && $this->isDueWindowOpen($row),
        ]);
    }

    public function submit(Request $request, string $id)
    {
        if ($request->user()->role !== 'trainee') {
            return response()->json(['message' => 'Disponível apenas para treinandos.'], 403);
        }

        $row = EnrollmentFollowUp::query()
            ->whereKey($id)
            ->with(['enrollment.training'])
            ->firstOrFail();

        if ((int) $row->enrollment->user_id !== (int) $request->user()->id) {
            return response()->json(['message' => 'Acesso negado.'], 403);
        }

        if ($row->status !== 'pending') {
            return response()->json(['message' => 'Esta reavaliação já foi concluída.'], 422);
        }

        if (! $this->isDueWindowOpen($row)) {
            return response()->json(['message' => 'A reavaliação só pode ser preenchida a partir da data prevista.'], 423);
        }

        $data = $request->validate([
            'responses' => ['required', 'array'],
        ]);

        $questions = FollowUpDefinition::questionsForTraining($row->enrollment->training);
        $this->assertResponsesValid($questions, $data['responses']);

        $row->update([
            'responses' => $data['responses'],
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        return response()->json($row->fresh());
    }

    protected function isDueWindowOpen(EnrollmentFollowUp $row): bool
    {
        $start = $row->due_at->copy()->timezone(config('app.timezone'))->startOfDay();

        return now()->greaterThanOrEqualTo($start);
    }

    /**
     * @param  list<array<string, mixed>>  $questions
     */
    protected function assertResponsesValid(array $questions, array $responses): void
    {
        foreach ($questions as $q) {
            $key = (string) ($q['key'] ?? '');
            if ($key === '') {
                continue;
            }
            $optional = ! empty($q['optional']);
            $type = (string) ($q['type'] ?? 'text');
            $raw = $responses[$key] ?? null;

            if ($optional && ($raw === null || $raw === '')) {
                continue;
            }

            if (! $optional && ($raw === null || $raw === '')) {
                throw ValidationException::withMessages([
                    "responses.$key" => ['Resposta obrigatória.'],
                ]);
            }

            if ($raw === null || $raw === '') {
                continue;
            }

            if ($type === 'likert_5') {
                $n = is_numeric($raw) ? (int) $raw : 0;
                if ($n < 1 || $n > 5) {
                    throw ValidationException::withMessages([
                        "responses.$key" => ['Indique um valor entre 1 e 5.'],
                    ]);
                }
            } elseif ($type === 'choice') {
                $allowed = collect($q['options'] ?? [])->pluck('value')->map(fn ($v) => (string) $v)->all();
                if (! in_array((string) $raw, $allowed, true)) {
                    throw ValidationException::withMessages([
                        "responses.$key" => ['Opção inválida.'],
                    ]);
                }
            } elseif ($type === 'text') {
                if (! is_string($raw) || mb_strlen($raw) > 5000) {
                    throw ValidationException::withMessages([
                        "responses.$key" => ['Texto inválido (máx. 5000 caracteres).'],
                    ]);
                }
            }
        }
    }
}
