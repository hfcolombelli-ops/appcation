<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CertificateController;
use App\Http\Controllers\Api\CredentialController;
use App\Http\Controllers\Api\EnrollmentController;
use App\Http\Controllers\Api\EquipmentCatalogController;
use App\Http\Controllers\Api\FollowUpAssessmentController;
use App\Http\Controllers\Api\GoogleAuthController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\InstitutionController;
use App\Http\Controllers\Api\InstitutionDashboardController;
use App\Http\Controllers\Api\InstitutionEquipmentController;
use App\Http\Controllers\Api\InstitutionManufacturerEndorsementController;
use App\Http\Controllers\Api\InstructorDashboardController;
use App\Http\Controllers\Api\InstructorSeasonRankController;
use App\Http\Controllers\Api\ManufacturerDashboardController;
use App\Http\Controllers\Api\ManufacturerDocumentController;
use App\Http\Controllers\Api\ManufacturerEquipmentAttachmentController;
use App\Http\Controllers\Api\ManufacturerEquipmentController;
use App\Http\Controllers\Api\ManufacturerPrizeCatalogController;
use App\Http\Controllers\Api\ManufacturerPrizeController;
use App\Http\Controllers\Api\ManufacturerProfileController;
use App\Http\Controllers\Api\ManufacturerSeasonController;
use App\Http\Controllers\Api\ManufacturerValidationController;
use App\Http\Controllers\Api\PrivacyController;
use App\Http\Controllers\Api\QuestionnaireController;
use App\Http\Controllers\Api\RealtimeController;
use App\Http\Controllers\Api\TraineeParkEquipmentController;
use App\Http\Controllers\Api\TraineeProfileController;
use App\Http\Controllers\Api\TraineeStateController;
use App\Http\Controllers\Api\TrainingController;
use App\Http\Controllers\Api\TrainingQuestionnaireController;
use App\Http\Controllers\Api\TrainingRequestCatalogController;
use App\Http\Controllers\Api\TrainingRequestController;
use App\Http\Controllers\Api\TrainingTemplateController;
use App\Http\Controllers\CertificateVerificationController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class);

Route::get('/public/certificates/verify/{code}', [CertificateVerificationController::class, 'show'])
    ->where('code', '.+')
    ->middleware('throttle:60,1');

Route::get('/privacy/policy-meta', [PrivacyController::class, 'policyMeta']);

Route::post('/auth/register', [AuthController::class, 'register'])
    ->middleware('throttle:auth-register');
Route::post('/auth/login', [AuthController::class, 'login'])
    ->middleware('throttle:auth-login');
Route::post('/auth/google', [GoogleAuthController::class, 'callback'])
    ->middleware('throttle:auth-google');

Route::get('/public/institution-catalog', [InstitutionController::class, 'publicCatalog'])
    ->middleware('throttle:public-read');

Route::get('/public/manufacturer-prizes', [ManufacturerPrizeCatalogController::class, 'index'])
    ->middleware('throttle:public-read');

Route::get('/realtime/client-config', [RealtimeController::class, 'clientConfig'])
    ->middleware('throttle:public-read');

Route::middleware(['auth:sanctum', 'throttle:api-user'])->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::patch('/me/notification-preferences', [AuthController::class, 'updateNotificationPreferences'])
        ->middleware('throttle:sensitive');
    Route::patch('/me/institution', [AuthController::class, 'updateMyInstitution']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::post('/me/lgpd-consent', [PrivacyController::class, 'storeConsent'])
        ->middleware('throttle:sensitive');
    Route::get('/me/personal-data-export', [PrivacyController::class, 'exportPersonalData'])
        ->middleware('throttle:gdpr-heavy');
    Route::post('/me/request-account-deletion', [PrivacyController::class, 'requestAccountDeletion'])
        ->middleware('throttle:gdpr-heavy');

    Route::get('/institutions', [InstitutionController::class, 'index']);
    Route::post('/institutions', [InstitutionController::class, 'store']);

    Route::get('/catalog/manufacturers', [CredentialController::class, 'manufacturersCatalog']);
    Route::get('/catalog/equipment-categories', [EquipmentCatalogController::class, 'categories']);
    Route::get('/catalog/training-request-options', [TrainingRequestCatalogController::class, 'options']);
    Route::get('/catalog/official-training-templates', [TrainingController::class, 'officialTemplatesCatalog']);
    Route::post('/credentials/institution', [CredentialController::class, 'applyInstitution']);
    Route::post('/credentials/manufacturer', [CredentialController::class, 'applyManufacturer']);
    Route::get('/credentials/me', [CredentialController::class, 'mine']);
    Route::get('/credentials/institution/queue', [CredentialController::class, 'institutionQueue']);
    Route::patch('/credentials/institution/{id}', [CredentialController::class, 'institutionDecide'])
        ->middleware('throttle:sensitive');
    Route::get('/credentials/manufacturer/queue', [CredentialController::class, 'manufacturerQueue']);
    Route::patch('/credentials/manufacturer/{id}', [CredentialController::class, 'manufacturerDecide'])
        ->middleware('throttle:sensitive');

    Route::get('/institution/manufacturer-endorsement-queue', [InstitutionManufacturerEndorsementController::class, 'queue']);
    Route::post('/institution/manufacturer-endorsements/{id}/endorse', [InstitutionManufacturerEndorsementController::class, 'endorse'])
        ->middleware('throttle:sensitive');

    Route::post('/training-requests', [TrainingRequestController::class, 'store']);
    Route::get('/training-requests/mine', [TrainingRequestController::class, 'mine']);
    Route::get('/institution/training-requests', [TrainingRequestController::class, 'institutionIndex']);
    Route::patch('/institution/training-requests/{id}', [TrainingRequestController::class, 'institutionUpdate'])
        ->middleware('throttle:sensitive');

    Route::get('/me/certificates', [CertificateController::class, 'index']);
    Route::get('/me/certificates/{id}', [CertificateController::class, 'show']);
    Route::get('/me/certificates/{id}/pdf', [CertificateController::class, 'downloadPdf']);

    Route::get('/institution/dashboard-summary', [InstitutionDashboardController::class, 'show']);
    Route::get('/institution/dashboard-summary/export.csv', [InstitutionDashboardController::class, 'exportCsv'])
        ->middleware('throttle:sensitive');
    Route::get('/institution/dashboard-summary/export.pdf', [InstitutionDashboardController::class, 'exportPdf'])
        ->middleware('throttle:sensitive');
    Route::get('/institution/my-trainings', [InstitutionController::class, 'myTrainingsAsGestor']);
    Route::get('/institution/approved-instructors', [InstitutionController::class, 'approvedInstructors']);

    Route::get('/institution/equipment-templates', [InstitutionEquipmentController::class, 'templates']);
    Route::get('/institution/catalog-equipment/{catalogId}/image', [InstitutionEquipmentController::class, 'downloadCatalogImage']);
    Route::get('/institution/equipment', [InstitutionEquipmentController::class, 'index']);
    Route::post('/institution/equipment', [InstitutionEquipmentController::class, 'store']);
    Route::put('/institution/equipment/{id}', [InstitutionEquipmentController::class, 'update']);
    Route::delete('/institution/equipment/{id}', [InstitutionEquipmentController::class, 'destroy']);

    Route::get('/me/trainee-profile', [TraineeProfileController::class, 'show']);
    Route::put('/me/trainee-profile', [TraineeProfileController::class, 'update']);
    Route::get('/me/institution-park-equipment', [TraineeParkEquipmentController::class, 'index']);
    Route::get('/me/trainee-state', [TraineeStateController::class, 'show']);

    Route::get('/me/follow-up-assessments', [FollowUpAssessmentController::class, 'index'])
        ->middleware('trainee.lgpd');
    Route::get('/me/follow-up-assessments/{id}', [FollowUpAssessmentController::class, 'show'])
        ->middleware('trainee.lgpd');
    Route::post('/me/follow-up-assessments/{id}/submit', [FollowUpAssessmentController::class, 'submit'])
        ->middleware('trainee.lgpd');

    Route::post('/enrollments/join', [EnrollmentController::class, 'join']);
    Route::get('/enrollments/mine', [EnrollmentController::class, 'mine']);
    Route::get('/enrollments/{enrollment}', [EnrollmentController::class, 'show']);

    Route::get('/instructor/dashboard-summary', [InstructorDashboardController::class, 'show']);
    Route::get('/instructor/season-ranks', [InstructorSeasonRankController::class, 'index']);

    Route::post('/trainings/from-template/{template}', [TrainingTemplateController::class, 'instantiate']);

    Route::get('/trainings/{training}/enrollments', [EnrollmentController::class, 'forTraining']);
    Route::post('/trainings/{training}/enrollments/{enrollment}/certificate', [EnrollmentController::class, 'issueCertificateForTraining'])
        ->middleware('throttle:sensitive');
    Route::get('/trainings/{training}/certificates/{certificate}/pdf', [CertificateController::class, 'instructorDownloadPdf']);
    Route::get('/trainings/{training}/questionnaire', [QuestionnaireController::class, 'show'])
        ->middleware('trainee.lgpd');
    Route::post('/trainings/{training}/questionnaire', [TrainingQuestionnaireController::class, 'sync']);

    Route::post('/questionnaire/answers', [QuestionnaireController::class, 'store'])
        ->middleware('trainee.lgpd');

    Route::get('/trainings/{training}/live-state', [TrainingController::class, 'liveState'])
        ->middleware('trainee.lgpd');

    Route::get('/manufacturer/profile', [ManufacturerProfileController::class, 'show']);
    Route::put('/manufacturer/profile', [ManufacturerProfileController::class, 'update']);
    Route::get('/manufacturer/dashboard-summary', [ManufacturerDashboardController::class, 'show']);
    Route::get('/manufacturer/dashboard-summary/export.csv', [ManufacturerDashboardController::class, 'exportCsv'])
        ->middleware('throttle:sensitive');
    Route::get('/manufacturer/dashboard-summary/export.pdf', [ManufacturerDashboardController::class, 'exportPdf'])
        ->middleware('throttle:sensitive');
    Route::get('/manufacturer/seasons', [ManufacturerSeasonController::class, 'index']);
    Route::post('/manufacturer/seasons', [ManufacturerSeasonController::class, 'store']);
    Route::patch('/manufacturer/seasons/{id}', [ManufacturerSeasonController::class, 'update']);
    Route::delete('/manufacturer/seasons/{id}', [ManufacturerSeasonController::class, 'destroy']);
    Route::get('/manufacturer/seasons/{id}/leaderboard', [ManufacturerSeasonController::class, 'leaderboard']);
    Route::post('/manufacturer/seasons/{id}/recompute', [ManufacturerSeasonController::class, 'recompute']);
    Route::get('/manufacturer/prizes', [ManufacturerPrizeController::class, 'index']);
    Route::post('/manufacturer/prizes', [ManufacturerPrizeController::class, 'store']);
    Route::patch('/manufacturer/prizes/{id}', [ManufacturerPrizeController::class, 'update']);
    Route::delete('/manufacturer/prizes/{id}', [ManufacturerPrizeController::class, 'destroy']);
    Route::get('/manufacturer/review-queue', [ManufacturerValidationController::class, 'reviewQueue']);
    Route::post('/manufacturer/request-validation', [ManufacturerValidationController::class, 'requestValidation'])
        ->middleware('throttle:sensitive');
    Route::patch('/manufacturer/reviews/{manufacturer}', [ManufacturerValidationController::class, 'review'])
        ->middleware('throttle:sensitive');

    Route::get('/manufacturer/documents', [ManufacturerDocumentController::class, 'index']);
    Route::post('/manufacturer/documents', [ManufacturerDocumentController::class, 'store']);
    Route::get('/manufacturer/documents/{id}/download', [ManufacturerDocumentController::class, 'download']);
    Route::delete('/manufacturer/documents/{id}', [ManufacturerDocumentController::class, 'destroy']);

    Route::get('/manufacturer/equipment', [ManufacturerEquipmentController::class, 'index']);
    Route::post('/manufacturer/equipment', [ManufacturerEquipmentController::class, 'store']);
    Route::put('/manufacturer/equipment/{id}', [ManufacturerEquipmentController::class, 'update']);
    Route::delete('/manufacturer/equipment/{id}', [ManufacturerEquipmentController::class, 'destroy']);
    Route::post('/manufacturer/equipment/{id}/attachments', [ManufacturerEquipmentAttachmentController::class, 'store']);
    Route::get('/manufacturer/equipment/{id}/attachments/{attachmentType}/download', [ManufacturerEquipmentAttachmentController::class, 'download']);

    Route::apiResource('trainings', TrainingController::class);

    Route::post('/realtime/trainings/{training}/command', [RealtimeController::class, 'command'])
        ->middleware('throttle:realtime-command');
});

Route::get('/realtime/health', [RealtimeController::class, 'health']);
