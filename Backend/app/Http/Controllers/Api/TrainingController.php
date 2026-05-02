<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Training;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class TrainingController extends Controller
{
    public function index()
    {
        return Training::query()
            ->latest()
            ->limit(50)
            ->get();
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'institution_id' => ['required', 'integer', 'exists:institutions,id'],
            'manufacturer_id' => ['nullable', 'integer', 'exists:manufacturers,id'],
            'equipment_id' => ['nullable', 'integer', 'exists:equipment,id'],
            'title' => ['required', 'string', 'max:180'],
            'type' => ['required', 'in:official,custom'],
            'scheduled_at' => ['nullable', 'date'],
            'status' => ['nullable', 'in:draft,scheduled,in_progress,finished,cancelled'],
        ]);

        $data['instructor_id'] = $request->user()->id;
        $data['join_hash'] = Str::lower(Str::random(12));
        $data['status'] = $data['status'] ?? 'draft';

        $training = Training::create($data);

        return response()->json($training, 201);
    }

    public function show(string $id)
    {
        return Training::findOrFail($id);
    }

    public function update(Request $request, string $id)
    {
        $training = Training::findOrFail($id);

        $data = $request->validate([
            'title' => ['sometimes', 'string', 'max:180'],
            'type' => ['sometimes', 'in:official,custom'],
            'scheduled_at' => ['nullable', 'date'],
            'status' => ['sometimes', 'in:draft,scheduled,in_progress,finished,cancelled'],
        ]);

        $training->update($data);

        return response()->json($training);
    }

    public function destroy(string $id)
    {
        $training = Training::findOrFail($id);
        $training->delete();

        return response()->noContent();
    }
}
