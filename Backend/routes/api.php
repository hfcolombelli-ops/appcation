<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EnrollmentController;
use App\Http\Controllers\Api\GoogleAuthController;
use App\Http\Controllers\Api\InstitutionController;
use App\Http\Controllers\Api\InstructorDashboardController;
use App\Http\Controllers\Api\ManufacturerEquipmentController;
use App\Http\Controllers\Api\ManufacturerProfileController;
use App\Http\Controllers\Api\PrivacyController;
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

Route::get('/privacy/policy-meta', [PrivacyController::class, 'policyMeta']);

Route::post('/auth/register', [AuthController::class, 'register'])
    ->middleware('throttle:15,60');
Route::post('/auth/login', [AuthController::class, 'login'])
    ->middleware('throttle:8,15');
Route::post('/auth/google', [GoogleAuthController::class, 'callback'])
    ->middleware('throttle:15,60');

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::post('/me/lgpd-consent', [PrivacyController::class, 'storeConsent']);
    Route::get('/me/personal-data-export', [PrivacyController::class, 'exportPersonalData']);
    Route::post('/me/request-account-deletion', [PrivacyController::class, 'requestAccountDeletion']);

    Route::get('/institutions', [InstitutionController::class, 'index']);
    Route::post('/institutions', [InstitutionController::class, 'store']);

    Route::get('/me/trainee-profile', [TraineeProfileController::class, 'show']);
    Route::put('/me/trainee-profile', [TraineeProfileController::class, 'update'])
        ->middleware('trainee.lgpd');
    Route::get('/me/trainee-state', [TraineeStateController::class, 'show']);

    Route::post('/enrollments/join', [EnrollmentController::class, 'join'])
        ->middleware('trainee.lgpd');
    Route::get('/enrollments/mine', [EnrollmentController::class, 'mine']);
    Route::get('/enrollments/{enrollment}', [EnrollmentController::class, 'show']);

    Route::get('/instructor/dashboard-summary', [InstructorDashboardController::class, 'show']);

    Route::get('/trainings/{training}/enrollments', [EnrollmentController::class, 'forTraining']);
    Route::get('/trainings/{training}/questionnaire', [QuestionnaireController::class, 'show'])
        ->middleware('trainee.lgpd');
    Route::post('/trainings/{training}/questionnaire', [TrainingQuestionnaireController::class, 'sync']);

    Route::post('/questionnaire/answers', [QuestionnaireController::class, 'store'])
        ->middleware('trainee.lgpd');

    Route::get('/trainings/{training}/live-state', [TrainingController::class, 'liveState'])
        ->middleware('trainee.lgpd');

    Route::get('/manufacturer/profile', [ManufacturerProfileController::class, 'show']);
    Route::put('/manufacturer/profile', [ManufacturerProfileController::class, 'update']);
    Route::get('/manufacturer/equipment', [ManufacturerEquipmentController::class, 'index']);
    Route::post('/manufacturer/equipment', [ManufacturerEquipmentController::class, 'store']);
    Route::put('/manufacturer/equipment/{id}', [ManufacturerEquipmentController::class, 'update']);
    Route::delete('/manufacturer/equipment/{id}', [ManufacturerEquipmentController::class, 'destroy']);

    Route::apiResource('trainings', TrainingController::class);

    Route::post('/realtime/trainings/{training}/command', [RealtimeController::class, 'command']);
});

Route::get('/realtime/health', [RealtimeController::class, 'health']);
