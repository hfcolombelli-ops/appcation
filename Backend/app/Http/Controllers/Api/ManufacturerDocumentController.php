<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ManufacturerDocument;
use App\Support\ManufacturerRegistrationSupport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

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

        $validated = $request->validate([
            'search' => ['nullable', 'string', 'max:120'],
            'page' => ['nullable', 'integer', 'min:1'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ]);

        $page = max(1, (int) ($validated['page'] ?? 1));
        $perPage = min(50, max(1, (int) ($validated['per_page'] ?? 20)));

        $q = ManufacturerDocument::query()->where('manufacturer_id', $mid);

        if ($request->filled('search')) {
            $raw = trim((string) $request->query('search'));
            $term = '%'.str_replace(['%', '_'], ['\\%', '\\_'], mb_strtolower($raw)).'%';
            $q->where(function ($w) use ($term) {
                $w->whereRaw('LOWER(original_filename) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(COALESCE(document_kind, "")) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(COALESCE(notes, "")) LIKE ?', [$term]);
            });
        }

        $paginator = $q->latest()->paginate($perPage, ['*'], 'page', $page);

        return response()->json([
            'items' => $paginator->items(),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => max(1, $paginator->lastPage()),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        $allowedKinds = array_merge(ManufacturerRegistrationSupport::REQUIRED_DOCUMENT_KINDS, ['other']);

        $data = $request->validate([
            'file' => ['required', 'file', 'max:12288', 'mimes:pdf,jpg,jpeg,png,webp'],
            'document_kind' => ['nullable', 'string', 'max:80', Rule::in($allowedKinds)],
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
