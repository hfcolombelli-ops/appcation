<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ManufacturerInstructor;
use App\Models\Training;
use App\Support\TrainingCloner;
use Illuminate\Http\Request;

class TrainingTemplateController extends Controller
{
    /**
     * Instancia um treinamento operacional a partir de um template oficial do fabricante.
     */
    public function instantiate(Request $request, string $templateId)
    {
        if (! in_array($request->user()->role, ['instructor', 'institution_admin'], true)) {
            return response()->json(['message' => 'Apenas instrutores ou gestores podem instanciar templates.'], 403);
        }

        $template = Training::query()->findOrFail($templateId);

        if (! $template->is_official_template || $template->manufacturer_id === null) {
            return response()->json(['message' => 'Template oficial não encontrado.'], 404);
        }

        $data = $request->validate([
            'institution_id' => ['required', 'integer', 'exists:institutions,id'],
            'title' => ['nullable', 'string', 'max:180'],
            'scheduled_at' => ['nullable', 'date'],
        ]);

        $user = $request->user();

        if ($user->role === 'instructor') {
            $approved = ManufacturerInstructor::query()
                ->where('manufacturer_id', $template->manufacturer_id)
                ->where('instructor_id', $user->id)
                ->where('status', 'approved')
                ->exists();
            if (! $approved) {
                return response()->json(['message' => 'É necessário homologação ativa com este fabricante (credenciamento duplo).'], 403);
            }
        }

        if ($user->role === 'institution_admin') {
            if ($user->institution_id === null || (int) $user->institution_id !== (int) $data['institution_id']) {
                return response()->json(['message' => 'Use a instituição vinculada ao seu perfil de gestor.'], 403);
            }
        }

        $scheduled = isset($data['scheduled_at']) ? new \DateTimeImmutable($data['scheduled_at']) : null;

        $training = TrainingCloner::instantiateFromTemplate(
            $template,
            $request->user(),
            (int) $data['institution_id'],
            $data['title'] ?? null,
            $scheduled,
        );

        return response()->json($training->load('institution:id,name'), 201);
    }
}
