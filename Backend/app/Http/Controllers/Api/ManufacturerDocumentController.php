<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ManufacturerDocument;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * Documentos enviados pelo fabricante (Fluxxo / homologação).
 * Disco: `config('filesystems.default')` — em dev costuma ser `local`; em produção use `FILESYSTEM_DISK=s3` e variáveis AWS_*.
 */
class ManufacturerDocumentController extends Controller
{
    protected function documentsDisk(): string
    {
        return config('filesystems.default', 'local');
    }

    protected function manufacturerId(Request $request): ?int
    {
        $user = $request->user();
        if ($user->role !== 'manufacturer_admin' || $user->manufacturer_id === null) {
            return null;
        }

        return (int) $user->manufacturer_id;
    }

    public function index(Request $request)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $rows = ManufacturerDocument::query()
            ->where('manufacturer_id', $mid)
            ->latest()
            ->limit(100)
            ->get();

        return response()->json($rows);
    }

    public function store(Request $request)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $data = $request->validate([
            'file' => ['required', 'file', 'max:12288', 'mimes:pdf,jpg,jpeg,png,webp'],
            'document_kind' => ['nullable', 'string', 'max:80'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ]);

        $file = $request->file('file');
        $ext = $file->guessExtension() ?: $file->extension() ?: 'bin';
        $safeName = Str::lower(Str::random(24)).'.'.$ext;
        $dir = "manufacturer-documents/{$mid}";
        $storedPath = $file->storeAs($dir, $safeName, $this->documentsDisk());

        $row = ManufacturerDocument::create([
            'manufacturer_id' => $mid,
            'stored_path' => $storedPath,
            'original_filename' => $file->getClientOriginalName(),
            'mime_type' => $file->getClientMimeType(),
            'size_bytes' => $file->getSize() ?: 0,
            'document_kind' => $data['document_kind'] ?? 'other',
            'notes' => $data['notes'] ?? null,
        ]);

        return response()->json($row, 201);
    }

    public function destroy(Request $request, string $id)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $doc = ManufacturerDocument::query()
            ->whereKey($id)
            ->where('manufacturer_id', $mid)
            ->firstOrFail();

        $disk = $this->documentsDisk();
        if (Storage::disk($disk)->exists($doc->stored_path)) {
            Storage::disk($disk)->delete($doc->stored_path);
        }

        $doc->delete();

        return response()->json(['message' => 'Documento removido.']);
    }

    public function download(Request $request, string $id)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $doc = ManufacturerDocument::query()
            ->whereKey($id)
            ->where('manufacturer_id', $mid)
            ->firstOrFail();

        $disk = $this->documentsDisk();

        if (! Storage::disk($disk)->exists($doc->stored_path)) {
            return response()->json(['message' => 'Ficheiro não encontrado no armazenamento.'], 404);
        }

        return Storage::disk($disk)->download(
            $doc->stored_path,
            $doc->original_filename,
            ['Content-Type' => $doc->mime_type ?? 'application/octet-stream'],
        );
    }
}
