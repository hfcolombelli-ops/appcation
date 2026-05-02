<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\QuestionnaireController;
use App\Http\Controllers\Api\RealtimeController;
use App\Http\Controllers\Api\TrainingController;
use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'status' => 'ok',
        'app' => config('app.name'),
    ]);
});

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::apiResource('trainings', TrainingController::class);

    Route::get('/trainings/{training}/questionnaire', [QuestionnaireController::class, 'show']);
    Route::post('/questionnaire/answers', [QuestionnaireController::class, 'store']);

    Route::post('/realtime/trainings/{training}/command', [RealtimeController::class, 'command']);
});

Route::get('/realtime/health', [RealtimeController::class, 'health']);
