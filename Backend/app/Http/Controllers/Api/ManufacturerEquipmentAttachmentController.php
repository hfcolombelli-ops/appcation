<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\RequiresManufacturerApproved;
use App\Http\Controllers\Controller;
use App\Models\Equipment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/**
 * Anexos do equipamento no catálogo do fabricante (imagem, manuais, vídeo).
 */
class ManufacturerEquipmentAttachmentController extends Controller
{
    use RequiresManufacturerApproved;

    protected function documentsDisk(): string
    {
        return config('filesystems.default', 'local');
    }

    protected function manufacturerEquipment(Request $request, string $id): Equipment|JsonResponse
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $eq = Equipment::query()->find($id);
        if ($eq === null || $eq->institution_id !== null || (int) $eq->manufacturer_id !== (int) $user->manufacturer_id) {
            return response()->json(['message' => 'Equipamento não encontrado.'], 404);
        }

        return $eq;
    }

    /**
     * @return array{0: string, 1: list<string>}
     */
    protected function columnAndFileRules(string $type): array
    {
        return match ($type) {
            'image' => ['image_stored_path', ['required', 'file', 'max:5120', 'mimes:jpg,jpeg,png']],
            'operator_manual' => ['manual_operator_stored_path', ['required', 'file', 'max:51200', 'mimes:pdf']],
            'maintenance_manual' => ['manual_maintenance_stored_path', ['required', 'file', 'max:51200', 'mimes:pdf']],
            'datasheet' => ['datasheet_stored_path', ['required', 'file', 'max:10240', 'mimes:pdf']],
            'intro_video' => ['intro_video_stored_path', ['required', 'file', 'max:204800', 'mimes:mp4']],
            default => ['', []],
        };
    }

    public function store(Request $request, string $id)
    {
        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $eq = $this->manufacturerEquipment($request, $id);
        if ($eq instanceof JsonResponse) {
            return $eq;
        }

        $data = $request->validate([
            'attachment_type' => ['required', 'string', Rule::in([
                'image', 'operator_manual', 'maintenance_manual', 'datasheet', 'intro_video',
            ])],
        ]);

        [$column, $fileRules] = $this->columnAndFileRules($data['attachment_type']);
        if ($column === '') {
            return response()->json(['message' => 'Tipo de anexo inválido.'], 422);
        }

        $request->validate(['file' => $fileRules]);

        $file = $request->file('file');
        $disk = $this->documentsDisk();
        $mid = (int) $eq->manufacturer_id;
        $dir = "equipment-files/{$mid}/{$eq->id}";
        $ext = $file->guessExtension() ?: $file->extension() ?: 'bin';
        $safeName = Str::lower(Str::random(20)).'.'.Str::lower($ext);
        $storedPath = $file->storeAs($dir, $safeName, $disk);

        $previous = $eq->{$column};
        if (is_string($previous) && $previous !== '' && Storage::disk($disk)->exists($previous)) {
            Storage::disk($disk)->delete($previous);
        }

        $eq->update([$column => $storedPath]);

        return response()->json(['equipment' => $eq->fresh()]);
    }

    public function download(Request $request, string $id, string $attachmentType)
    {
        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $eq = $this->manufacturerEquipment($request, $id);
        if ($eq instanceof JsonResponse) {
            return $eq;
        }

        if (! in_array($attachmentType, ['image', 'operator_manual', 'maintenance_manual', 'datasheet', 'intro_video'], true)) {
            return response()->json(['message' => 'Tipo inválido.'], 422);
        }

        [$column] = $this->columnAndFileRules($attachmentType);
        $path = $eq->{$column};
        if (! is_string($path) || $path === '') {
            return response()->json(['message' => 'Ficheiro não encontrado.'], 404);
        }

        $disk = $this->documentsDisk();
        if (! Storage::disk($disk)->exists($path)) {
            return response()->json(['message' => 'Ficheiro em falta no armazenamento.'], 404);
        }

        $downloadName = match ($attachmentType) {
            'image' => 'equipamento-imagem.jpg',
            'operator_manual' => 'manual-operador.pdf',
            'maintenance_manual' => 'manual-manutencao.pdf',
            'datasheet' => 'ficha-tecnica.pdf',
            default => 'video-introducao.mp4',
        };

        return Storage::disk($disk)->download($path, $downloadName);
    }
}
