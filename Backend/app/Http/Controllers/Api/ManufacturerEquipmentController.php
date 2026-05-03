<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\RequiresManufacturerApproved;
use App\Http\Controllers\Controller;
use App\Models\Equipment;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * Catálogo de equipamentos do fabricante (institution_id nulo).
 */
class ManufacturerEquipmentController extends Controller
{
    use RequiresManufacturerApproved;

    /**
     * @return list<string>
     */
    protected function allowedCategoryIds(): array
    {
        return collect(config('equipment.categories', []))
            ->pluck('id')
            ->map(fn ($id) => (string) $id)
            ->all();
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

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $allowed = $this->allowedCategoryIds();
        if ($request->filled('category')) {
            $cat = (string) $request->query('category');
            if (! in_array($cat, $allowed, true)) {
                return response()->json(['message' => 'Categoria inválida.'], 422);
            }
        }

        $q = Equipment::query()
            ->where('manufacturer_id', $mid)
            ->whereNull('institution_id')
            ->withCount([
                'trainings as official_templates_count' => function ($rel) {
                    $rel->where('is_official_template', true);
                },
            ]);

        if ($request->filled('category')) {
            $q->where('category', (string) $request->query('category'));
        }

        if ($request->filled('status')) {
            $q->where('status', (string) $request->query('status'));
        }

        if ($request->filled('search')) {
            $term = '%'.str_replace(['%', '_'], ['\\%', '\\_'], mb_strtolower(trim((string) $request->query('search')))).'%';
            $q->where(function ($w) use ($term) {
                $w->whereRaw('LOWER(name) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(model) LIKE ?', [$term])
                    ->orWhereRaw('LOWER(COALESCE(serial_number, "")) LIKE ?', [$term]);
            });
        }

        $rows = $q
            ->orderBy('name')
            ->orderBy('id')
            ->limit(200)
            ->get()
            ->map(function (Equipment $row) {
                $data = $row->toArray();
                $data['has_image'] = is_string($row->image_stored_path) && $row->image_stored_path !== '';

                return $data;
            });

        return response()->json($rows);
    }

    public function store(Request $request)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $allowed = $this->allowedCategoryIds();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:180'],
            'model' => ['required', 'string', 'max:120'],
            'firmware_version' => ['nullable', 'string', 'max:80'],
            'serial_number' => ['nullable', 'string', 'max:120'],
            'sector' => ['nullable', 'string', 'max:120'],
            'technical_specs' => ['nullable', 'array', 'max:40'],
            'technical_specs.*.label' => ['required', 'string', 'max:120'],
            'technical_specs.*.value' => ['required', 'string', 'max:500'],
            'category' => [
                Rule::requiredIf(function () use ($request) {
                    $p = $request->input('parent_equipment_id');

                    return $p === null || $p === '';
                }),
                'nullable',
                'string',
                'max:64',
                Rule::in($allowed),
            ],
            'intro_video_url' => ['nullable', 'string', 'max:500'],
            'default_training_hours' => ['nullable', 'integer', 'min:1', 'max:999'],
            'default_passing_score_percent' => ['nullable', 'integer', 'min:40', 'max:100'],
            'default_certificate_validity_months' => ['nullable', 'integer', 'min:1', 'max:240'],
            'default_reassessment_days' => ['nullable', 'integer', 'min:1', 'max:365'],
            'quantity' => ['nullable', 'integer', 'min:1'],
            'status' => ['nullable', 'string', 'max:40'],
            'parent_equipment_id' => ['nullable', 'integer', 'exists:equipment,id'],
        ]);

        $parentId = $data['parent_equipment_id'] ?? null;
        if ($parentId !== null) {
            $parent = Equipment::query()
                ->whereKey($parentId)
                ->where('manufacturer_id', $mid)
                ->whereNull('institution_id')
                ->first();
            if ($parent === null) {
                return response()->json(['message' => 'Equipamento de origem inválido ou de outro fabricante.'], 422);
            }
        }

        $category = $data['category'] ?? null;
        if ($parentId !== null && ($category === null || $category === '')) {
            $parent = Equipment::query()->find($parentId);
            $category = $parent?->category;
        }

        if ($category === null || $category === '') {
            return response()->json([
                'message' => 'A categoria é obrigatória para novos equipamentos.',
                'errors' => ['category' => ['Escolha uma categoria.']],
            ], 422);
        }

        $modelNormalized = mb_strtolower(trim($data['model']));
        if ($parentId === null) {
            $dup = Equipment::query()
                ->where('manufacturer_id', $mid)
                ->whereNull('institution_id')
                ->whereNull('parent_equipment_id')
                ->whereRaw('LOWER(TRIM(model)) = ?', [$modelNormalized])
                ->exists();
            if ($dup) {
                return response()->json([
                    'message' => 'Já existe um equipamento com este modelo no seu catálogo.',
                    'code' => 'equipment_model_duplicate',
                ], 422);
            }
        }

        $row = Equipment::create([
            'manufacturer_id' => $mid,
            'institution_id' => null,
            'parent_equipment_id' => $parentId,
            'name' => $data['name'],
            'model' => trim($data['model']),
            'firmware_version' => $data['firmware_version'] ?? null,
            'serial_number' => isset($data['serial_number']) ? trim((string) $data['serial_number']) : null,
            'sector' => $data['sector'] ?? null,
            'technical_specs' => $data['technical_specs'] ?? null,
            'category' => $category,
            'intro_video_url' => $data['intro_video_url'] ?? null,
            'default_training_hours' => $data['default_training_hours'] ?? null,
            'default_passing_score_percent' => $data['default_passing_score_percent'] ?? null,
            'default_certificate_validity_months' => $data['default_certificate_validity_months'] ?? null,
            'default_reassessment_days' => $data['default_reassessment_days'] ?? null,
            'quantity' => $data['quantity'] ?? 1,
            'status' => $data['status'] ?? 'active',
        ]);

        $fresh = $row->fresh();
        $fresh->loadCount([
            'trainings as official_templates_count' => function ($rel) {
                $rel->where('is_official_template', true);
            },
        ]);
        $payload = $fresh->toArray();
        $payload['has_image'] = false;

        return response()->json($payload, 201);
    }

    public function update(Request $request, string $id)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $row = Equipment::query()
            ->whereKey($id)
            ->where('manufacturer_id', $mid)
            ->whereNull('institution_id')
            ->firstOrFail();

        if ($row->hasChildVersions()) {
            return response()->json([
                'message' => 'Este registo tem versões derivadas — não pode ser alterado (histórico imutável). Crie uma nova versão em vez de editar.',
            ], 422);
        }

        $allowed = $this->allowedCategoryIds();

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:180'],
            'model' => ['sometimes', 'string', 'max:120'],
            'firmware_version' => ['sometimes', 'nullable', 'string', 'max:80'],
            'serial_number' => ['sometimes', 'nullable', 'string', 'max:120'],
            'sector' => ['sometimes', 'nullable', 'string', 'max:120'],
            'technical_specs' => ['sometimes', 'nullable', 'array', 'max:40'],
            'technical_specs.*.label' => ['required', 'string', 'max:120'],
            'technical_specs.*.value' => ['required', 'string', 'max:500'],
            'category' => ['sometimes', 'nullable', 'string', 'max:64', Rule::in($allowed)],
            'intro_video_url' => ['sometimes', 'nullable', 'string', 'max:500'],
            'default_training_hours' => ['sometimes', 'nullable', 'integer', 'min:1', 'max:999'],
            'default_passing_score_percent' => ['sometimes', 'nullable', 'integer', 'min:40', 'max:100'],
            'default_certificate_validity_months' => ['sometimes', 'nullable', 'integer', 'min:1', 'max:240'],
            'default_reassessment_days' => ['sometimes', 'nullable', 'integer', 'min:1', 'max:365'],
            'quantity' => ['sometimes', 'integer', 'min:1'],
            'status' => ['sometimes', 'string', 'max:40'],
        ]);

        if (isset($data['model']) && $row->parent_equipment_id === null) {
            $modelNormalized = mb_strtolower(trim($data['model']));
            $dup = Equipment::query()
                ->where('manufacturer_id', $mid)
                ->whereNull('institution_id')
                ->whereNull('parent_equipment_id')
                ->whereKeyNot($row->id)
                ->whereRaw('LOWER(TRIM(model)) = ?', [$modelNormalized])
                ->exists();
            if ($dup) {
                return response()->json([
                    'message' => 'Já existe um equipamento com este modelo no seu catálogo.',
                    'code' => 'equipment_model_duplicate',
                ], 422);
            }
        }

        $row->update($data);

        $fresh = $row->fresh();
        $fresh->loadCount([
            'trainings as official_templates_count' => function ($rel) {
                $rel->where('is_official_template', true);
            },
        ]);
        $payload = $fresh->toArray();
        $payload['has_image'] = is_string($fresh->image_stored_path) && $fresh->image_stored_path !== '';

        return response()->json($payload);
    }

    public function destroy(Request $request, string $id)
    {
        $mid = $this->manufacturerId($request);
        if ($mid === null) {
            return response()->json(['message' => 'Sem permissão.'], 403);
        }

        if ($r = $this->ensureManufacturerApproved($request)) {
            return $r;
        }

        $row = Equipment::query()
            ->whereKey($id)
            ->where('manufacturer_id', $mid)
            ->whereNull('institution_id')
            ->firstOrFail();

        if ($row->hasChildVersions()) {
            return response()->json([
                'message' => 'Remova primeiro as versões derivadas deste equipamento.',
            ], 422);
        }

        $row->delete();

        return response()->noContent();
    }
}
