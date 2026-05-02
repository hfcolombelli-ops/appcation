<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EnrollmentController;
use App\Http\Controllers\Api\InstitutionController;
use App\Http\Controllers\Api\InstructorDashboardController;
use App\Http\Controllers\Api\QuestionnaireController;
use App\Http\Controllers\Api\RealtimeController;
use App\Http\Controllers\Api\TraineeProfileController;
use App\Http\Controllers\Api\TraineeStateController;
use App\Http\Controllers\Api\TrainingController;
use App\Http\Controllers\Api\TrainingQuestionnaireController;
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

    Route::get('/institutions', [InstitutionController::class, 'index']);
    Route::post('/institutions', [InstitutionController::class, 'store']);

    Route::get('/me/trainee-profile', [TraineeProfileController::class, 'show']);
    Route::put('/me/trainee-profile', [TraineeProfileController::class, 'update']);
    Route::get('/me/trainee-state', [TraineeStateController::class, 'show']);

    Route::post('/enrollments/join', [EnrollmentController::class, 'join']);
    Route::get('/enrollments/mine', [EnrollmentController::class, 'mine']);
    Route::get('/enrollments/{enrollment}', [EnrollmentController::class, 'show']);

    Route::get('/instructor/dashboard-summary', [InstructorDashboardController::class, 'show']);

    Route::get('/trainings/{training}/enrollments', [EnrollmentController::class, 'forTraining']);
    Route::get('/trainings/{training}/questionnaire', [QuestionnaireController::class, 'show']);
    Route::post('/trainings/{training}/questionnaire', [TrainingQuestionnaireController::class, 'sync']);

    Route::post('/questionnaire/answers', [QuestionnaireController::class, 'store']);

    Route::apiResource('trainings', TrainingController::class);

    Route::post('/realtime/trainings/{training}/command', [RealtimeController::class, 'command']);
});

Route::get('/realtime/health', [RealtimeController::class, 'health']);
