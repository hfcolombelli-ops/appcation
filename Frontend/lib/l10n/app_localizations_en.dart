// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Appcation';

  @override
  String get loginShellTitle => 'Universal login';

  @override
  String get loginBrandTitle => 'App²cation';

  @override
  String get loginTagline => 'Clinical training with rhythm and clarity';

  @override
  String get loginAccessHeroTitle => 'Sign in to App²cation';

  @override
  String get loginAccessHeroSubtitle => 'Your training, your progress';

  @override
  String get loginNavQuestions => 'Questions?';

  @override
  String get loginNavStartNow => 'Get started';

  @override
  String get loginNavHaveAccount => 'I already have an account';

  @override
  String get loginFooterTerms => 'Terms of use';

  @override
  String get loginFooterPrivacy => 'Privacy policy';

  @override
  String get loginFooterCookies => 'Cookies';

  @override
  String get loginFooterHelp => 'Help center';

  @override
  String get loginFooterSystemsOk => 'All systems operational';

  @override
  String get loginFooterSupportPrefix => 'Can\'t access your account?';

  @override
  String get loginFooterSupportLink => 'Contact technical support';

  @override
  String get loginFooterSoon => 'Coming soon.';

  @override
  String get authTrackCpfLabel => 'Individual';

  @override
  String get authTrackCnpjLabel => 'Company';

  @override
  String get authTrackSegmentSubtitle =>
      'Individual (trainee or instructor) or company (manufacturer). Institutional managers are invited from the admin panel.';

  @override
  String get loginGoogleProfileSection => 'Profile (first Google sign-in)';

  @override
  String get loginGoogleProfileSectionCpf =>
      'Google — individual (trainee or instructor)';

  @override
  String get loginGoogleProfileSectionCnpj =>
      'Google — manufacturer (company / tax ID)';

  @override
  String get googleRoleTrainee => 'Trainee';

  @override
  String get googleRoleInstructor => 'Instructor';

  @override
  String get googleRoleInstitutionAdmin => 'Manager';

  @override
  String get googleRoleManufacturerAdmin => 'Manufacturer';

  @override
  String get mfgCompanyLabel => 'Company (manufacturer)';

  @override
  String get mfgCnpjOptionalLabel => 'Tax ID (optional)';

  @override
  String get institutionLoadingGoogle =>
      'Loading institutions… If the list is empty, register an institution first (instructor account) or use email and password.';

  @override
  String get institutionPickerLabelGoogle => 'Institution (manager)';

  @override
  String get googleConnecting => 'Connecting to Google…';

  @override
  String get googleContinue => 'Continue with Google';

  @override
  String get loginOrEmail => 'or email';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get valEmailRequired => 'Enter your email.';

  @override
  String get valEmailInvalid => 'Invalid email.';

  @override
  String get valPasswordRequired => 'Enter your password.';

  @override
  String get actionSignIn => 'Sign in';

  @override
  String get loginOrgHint =>
      'Hospital or clinic manager: use the email and password your organization created for you in the internal panel.';

  @override
  String get actionCreateAccount => 'Create account';

  @override
  String get actionBack => 'Back';

  @override
  String get registerSubtitle =>
      'Choose individual or company, the profile, then fill in the details.';

  @override
  String get registerAccountTypeTitle => 'Account type';

  @override
  String get registerAccountTypeTitleCpf => 'Profile (individual)';

  @override
  String get registerAccountTypeTitleCnpj => 'Manufacturer account (company)';

  @override
  String get registerManagerInviteHint =>
      'Institutional managers do not self-register here: the hospital or manufacturer creates access in the panel.';

  @override
  String get registerInstitutionsLoading =>
      'Loading institutions… If the list is empty, no hospitals are registered in the API yet.';

  @override
  String get fieldInstitution => 'Institution';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get valNameRequired => 'Enter your name.';

  @override
  String get fieldPasswordRegister => 'Password (min. 8 characters)';

  @override
  String get valPasswordMin8 => 'At least 8 characters.';

  @override
  String get fieldCompanyName => 'Company name';

  @override
  String get valCompanyNameRequired => 'Enter the company name.';

  @override
  String get actionCompleteRegistration => 'Complete registration';

  @override
  String get errApiConnection => 'Could not connect to the API.';

  @override
  String get errMfgNameRequired => 'Enter the company name.';

  @override
  String get errSelectInstitution => 'Select an institution from the list.';

  @override
  String get errGoogleClientId =>
      'Set GOOGLE_WEB_CLIENT_ID when running Flutter (same as GOOGLE_CLIENT_ID on the server).';

  @override
  String get errMfgNameBeforeGoogle =>
      'Enter the manufacturer name before continuing with Google.';

  @override
  String get errSelectInstitutionGoogle =>
      'Select an institution from the list (or wait for it to load).';

  @override
  String get shellTitleOverview => 'Overview';

  @override
  String get shellTitleCommandRoom => 'Command room';

  @override
  String get shellTitleNewTraining => 'New training';

  @override
  String get shellTitleCredentialing => 'Credentialing';

  @override
  String get shellTitleTrainingRequests => 'Training requests';

  @override
  String get shellTitleTechPark => 'Technology park';

  @override
  String get shellTitleEndorsements => 'Manufacturer endorsements';

  @override
  String get shellTitleFluxxoReview => 'Manufacturer review';

  @override
  String get shellNavDashboard => 'Dashboard';

  @override
  String get shellNavCommandRoom => 'Command room';

  @override
  String get shellNavTrainings => 'Trainings';

  @override
  String get shellNavTrainingRequests => 'Training requests';

  @override
  String get shellNavTechPark => 'Technology park';

  @override
  String get shellNavEndorsementsShort => 'Endorsements';

  @override
  String get shellNavFluxxoReview => 'Manufacturers';

  @override
  String get shellNavCredentialing => 'Credentialing';

  @override
  String get shellLinkInstitutionTitle => 'Link your institution';

  @override
  String get shellLinkInstitutionBody =>
      'Without this you cannot see training requests or the aggregated dashboard.';

  @override
  String get shellLinkInstitutionEmpty =>
      'No institutions in the API — create one under Credentialing (as instructor) or ask an administrator.';

  @override
  String get shellSaveLink => 'Save link';

  @override
  String get shellPickInstitution => 'Choose an institution.';

  @override
  String get shellAreaManager => 'Manager area';

  @override
  String get shellAreaInstructor => 'Instructor area';

  @override
  String get shellDefaultUserName => 'Instructor';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionRetry => 'Try again';

  @override
  String get dashExportCsvWebOnly =>
      'CSV export is only available in the web app.';

  @override
  String get dashExportPdfWebOnly =>
      'PDF export is only available in the web app.';

  @override
  String get dashLinkInstitutionForKpis =>
      'Link your institution using the orange banner at the top to see aggregated indicators.';

  @override
  String get dashKpiTrainings => 'Trainings';

  @override
  String get dashKpiFinished => 'Closed';

  @override
  String get dashKpiUniqueParticipants => 'Unique participants';

  @override
  String get dashKpiAvgCompleted => 'Average (completed)';

  @override
  String get dashKpiApprovalRate => 'Approval rate';

  @override
  String get dashSeasonRankingTitle => 'Season ranking';

  @override
  String get dashSeasonRankingHint =>
      'Official trainings linked to manufacturers count toward seasons defined by the manufacturer.';

  @override
  String get dashRecentTrainings => 'Recent trainings';

  @override
  String get dashNoTrainingsYet =>
      'No trainings yet. Create one under Trainings.';

  @override
  String dashSeasonPoints(Object points) {
    return '$points pts';
  }

  @override
  String get dashInstitutionKpisTitle => 'Institution indicators';

  @override
  String get dashInstitutionLgpdNote =>
      'Aggregated data — no individual identification (GDPR/LGPD).';

  @override
  String get dashExportCsv => 'Export CSV';

  @override
  String get dashExportPdf => 'Export PDF';

  @override
  String get dashKpiPendingRequests => 'Pending requests';

  @override
  String get dashKpiInstitutionTrainings => 'Trainings (institution)';

  @override
  String get dashKpiEnrollmentsTotal => 'Enrollments (total)';

  @override
  String get dashKpiCompleted => 'Completed';

  @override
  String get dashKpiCompletionRate => 'Completion rate';

  @override
  String get dashKpiAvgScoreOverall => 'Average score (overall)';

  @override
  String get dashByEquipment => 'By equipment';

  @override
  String get dashNoEquipmentData => 'No equipment breakdown yet.';

  @override
  String dashEquipmentSubtitle(
    Object enr,
    Object done,
    Object rate,
    Object avg,
  ) {
    return 'Enrollments: $enr · Completed: $done · Rate: $rate% · Avg. score: $avg';
  }

  @override
  String get dashSectorAveragesTitle => 'Averages by sector (completed)';

  @override
  String get dashNoSectorHistory => 'No sector history yet.';

  @override
  String dashSectorSubtitle(Object c, Object a) {
    return 'Completions: $c · Average: $a';
  }

  @override
  String get trainingSectionTitle => 'Setup';

  @override
  String get trainingFieldTitle => 'Training title';

  @override
  String get trainingTypeOfficial => 'Official';

  @override
  String get trainingTypeCustom => 'Custom';

  @override
  String get trainingScheduledLabel => 'Date/time (optional)';

  @override
  String get trainingScheduledHint => 'YYYY-MM-DD HH:MM';

  @override
  String get trainingCreateButton => 'Create training';

  @override
  String get trainingTemplateCardTitle => 'Official template (manufacturer)';

  @override
  String get trainingTemplateCardBody =>
      'Clones the approved questionnaire. Requires an approved endorsement with the manufacturer.';

  @override
  String get trainingTemplateLabel => 'Template';

  @override
  String get trainingUseTemplateButton =>
      'Use template with selected institution';

  @override
  String get trainingJoinCodeTitle => 'Join code (share with trainees)';

  @override
  String trainingInternalId(Object id) {
    return 'Internal ID: $id';
  }

  @override
  String get trainingPostRepescageTitle => 'Score after recovery';

  @override
  String get trainingPostRepescageBody =>
      'Replace vs average: “recovery only” uses only questions from the last error release; “global average” keeps the average of all released questions.';

  @override
  String get trainingPolicyFinalLabel => 'Final score policy';

  @override
  String get trainingPolicyFullAverage =>
      'Global average (all released questions)';

  @override
  String get trainingPolicyRecoveryOnly =>
      'Recovery only (replaces global average)';

  @override
  String get trainingVariantBankTitle => 'Variant bank (recovery)';

  @override
  String get trainingVariantBankSubtitle =>
      'If questions share the same variant group in the questionnaire, recovery suggests an equivalent question instead of repeating the same one.';

  @override
  String get trainingSavePolicyButton => 'Save policy';

  @override
  String get trainingQuestionnaireTitle => 'Questionnaire';

  @override
  String get trainingDefaultQuestionnaireBlockTitle => 'Assessment';

  @override
  String get trainLifecycleDraft => 'Draft';

  @override
  String get trainLifecycleScheduled => 'Scheduled';

  @override
  String get trainLifecycleInProgress => 'In progress';

  @override
  String get trainLifecycleFinished => 'Finished';

  @override
  String get enrollmentStatusWaiting => 'Waiting';

  @override
  String get enrollmentStatusActive => 'Active';

  @override
  String get enrollmentStatusCompleted => 'Completed';

  @override
  String get trainingAddQuestion => 'Question';

  @override
  String get trainingSaveQuestionnaireApi => 'Save questionnaire to API';

  @override
  String get trainingSnackPolicySaved => 'Recovery score policy saved.';

  @override
  String get trainingSnackFromTemplate =>
      'Training created from official template.';

  @override
  String get trainingPickInstitution => 'Select an institution.';

  @override
  String get trainingErrTitle => 'Enter a title.';

  @override
  String get trainingErrQuestionCorrect =>
      'Each question needs one correct option.';

  @override
  String get trainingErrQuestionValid =>
      'Add at least one valid question with 2+ options.';

  @override
  String get trainingSnackQuestionnaireSaved => 'Questionnaire saved.';

  @override
  String trainingQuestionN(Object n) {
    return 'Question $n';
  }

  @override
  String get trainingPromptLabel => 'Prompt';

  @override
  String get trainingOptionsMarkCorrect => 'Options (mark the correct one)';

  @override
  String trainingOptionN(Object n) {
    return 'Option $n';
  }

  @override
  String get comandoSnackBlockReleased =>
      'Next block released (or no pending blocks).';

  @override
  String get comandoSessionPaused => 'Session paused for trainees.';

  @override
  String get comandoSessionResumed => 'Session resumed.';

  @override
  String comandoStatusUpdate(Object status) {
    return 'Status: $status';
  }

  @override
  String get comandoSnackRepescageDone =>
      'Recovery applied — participants can fix wrong answers.';

  @override
  String get comandoActiveTraining => 'Active training';

  @override
  String comandoTrainingStatusHash(Object status, Object hash) {
    return 'Status: $status · Hash: $hash';
  }

  @override
  String get comandoParticipantsTitle => 'Participants';

  @override
  String get comandoNoParticipants => 'No enrolled participants.';

  @override
  String get comandoSessionControlTitle => 'Session control';

  @override
  String get comandoRepescageScope => 'Recovery scope';

  @override
  String get comandoRepescageScopeAll => 'Whole training (all wrong answers)';

  @override
  String get comandoBlockDefault => 'Block';

  @override
  String get comandoBtnStart => 'Start';

  @override
  String get comandoBtnReleaseBlock => 'Release next block';

  @override
  String get comandoBtnPause => 'Pause';

  @override
  String get comandoBtnResume => 'Resume';

  @override
  String get comandoBtnReschedule => 'Reschedule';

  @override
  String get comandoBtnClose => 'End';

  @override
  String comandoRepescageCount(Object count) {
    return 'Recovery ($count)';
  }

  @override
  String get comandoHelpFooter =>
      'Start releases the questionnaire to connected trainees. Recovery clears wrong answers; by block, only those in that block (tags when block accuracy is below 50%).';

  @override
  String comandoParticipantAnswers(
    Object answered,
    Object total,
    Object status,
  ) {
    return 'Answers $answered / $total · $status';
  }

  @override
  String get credSnackInstitutionCreated => 'Institution created.';

  @override
  String get credTitleInstitutions => 'Institutions';

  @override
  String get credIntroInstitutions =>
      'Register hospitals or units to link to trainings.';

  @override
  String get credFieldInstitutionName => 'Institution name';

  @override
  String get credFieldCnpjUnique => 'Tax ID (unique)';

  @override
  String get credBtnRegisterInstitution => 'Register institution';

  @override
  String credListedCount(Object count) {
    return 'Registered ($count)';
  }

  @override
  String get credDoubleTitle => 'Dual credentialing';

  @override
  String get credDoubleIntro =>
      'Link with institution and manufacturer approval.';

  @override
  String get credApplyInstitutionLabel => 'Request link to institution';

  @override
  String get credBtnRequestInstitution => 'Request institutional link';

  @override
  String get credApplyManufacturerLabel => 'Request manufacturer approval';

  @override
  String get credBtnRequestManufacturer => 'Request from manufacturer';

  @override
  String get credMyLinksTitle => 'My links';

  @override
  String get credMyLinksInstitutionsHeader => 'Institutions';

  @override
  String get credNoInstitutionalLink => 'No institutional link.';

  @override
  String get credMyLinksManufacturersHeader => 'Manufacturers';

  @override
  String get credNoManufacturerHomologation => 'No manufacturer approvals yet.';

  @override
  String get credQueueInstTitle => 'Link requests (manager)';

  @override
  String get credQueueInstBody =>
      'Instructors who requested a link with your institution. The “Pending” state leaves the queue after you decide.';

  @override
  String get credQueueManuTitle => 'Pending approvals (manufacturer)';

  @override
  String get credQueueManuBody =>
      'Instructor approvals with the manufacturer. Check institutional endorsement before approving.';

  @override
  String get credBtnApprove => 'Approve';

  @override
  String get credBtnReject => 'Reject';

  @override
  String credEndorsementWith(Object name) {
    return 'Institutional endorsement: $name';
  }

  @override
  String get credEndorsementPending => 'Institutional endorsement: pending';

  @override
  String get credSnackRequestSent => 'Request sent.';

  @override
  String get credSnackRequestManufacturerSent =>
      'Request sent to manufacturer.';

  @override
  String get credStatusPending => 'Pending';

  @override
  String get credStatusApproved => 'Approved';

  @override
  String get credStatusRejected => 'Rejected';

  @override
  String get credFeePaid => 'Fee marked as paid';

  @override
  String get credFeePending => 'Fee pending (if applicable)';

  @override
  String get trainReqLoadFailed => 'Failed to load.';

  @override
  String get trainReqSnackUpdated => 'Request updated.';

  @override
  String get trainReqUseOrangeBanner =>
      'Use the orange notice at the top to link your institution.';

  @override
  String get trainReqIntro =>
      'Approve, assign a credentialed instructor, and link the completed training when available.';

  @override
  String get trainReqEmpty => 'No training requests.';

  @override
  String trainReqReasonLine(Object text) {
    return 'Reason: $text';
  }

  @override
  String trainReqPriorityLine(Object text) {
    return 'Priority: $text';
  }

  @override
  String trainReqParkLine(Object name, Object detail) {
    return 'Tech park: $name ($detail)';
  }

  @override
  String trainReqPreferredDates(Object desired, Object limit) {
    return 'Preferred dates: $desired · deadline $limit';
  }

  @override
  String trainReqNotesLine(Object text) {
    return 'Notes: $text';
  }

  @override
  String get trainReqFieldStatus => 'Status';

  @override
  String get trainReqStatusPending => 'Pending';

  @override
  String get trainReqStatusApproved => 'Approved';

  @override
  String get trainReqStatusScheduled => 'Scheduled';

  @override
  String get trainReqStatusRejected => 'Rejected';

  @override
  String get trainReqStatusFulfilled => 'Completed';

  @override
  String get trainReqFieldAssignedInstructor => 'Assigned instructor';

  @override
  String get trainReqFieldFulfilledTraining => 'Completed training';

  @override
  String get trainReqDashNone => '—';

  @override
  String trainReqLinkedTraining(Object title, Object hash) {
    return 'Linked: $title · hash $hash';
  }

  @override
  String get trainReqBtnSaveChanges => 'Save changes';

  @override
  String get parkSnackPickCatalog => 'Choose a catalog model.';

  @override
  String get parkSnackUnitRegisteredPending => 'Unit registered (pending).';

  @override
  String get parkBannerLinkInstitutionFirst =>
      'Link your institution first using the banner above.';

  @override
  String get parkIntro =>
      'Each unit mirrors a model from the manufacturer\'s catalog. Initial state: pending; active when in approved use.';

  @override
  String get parkFilterByState => 'Filter by status';

  @override
  String get parkFilterChipAll => 'All';

  @override
  String get parkFilterChipPending => 'Pending';

  @override
  String get parkFilterChipActive => 'Active';

  @override
  String get parkFilterByCategory => 'Filter by category';

  @override
  String get parkFilterChipAllCategories => 'All';

  @override
  String get parkSectionAddUnit => 'Add unit';

  @override
  String get parkEmptyCatalog =>
      'No models in the manufacturer catalog yet — nothing to link.';

  @override
  String get parkCatalogDropdownHint => 'Catalog model';

  @override
  String get parkFieldSectorOptional => 'Sector / location (optional)';

  @override
  String get parkFieldSectorHintExample => 'e.g. ICU B, Block 3';

  @override
  String get parkBtnRegisterUnit => 'Register unit';

  @override
  String parkUnitsCount(Object count) {
    return 'Units ($count)';
  }

  @override
  String get parkEmptyPark => 'No units in the park.';

  @override
  String get parkEquipmentFallbackName => 'Equipment';

  @override
  String get parkBtnActivate => 'Activate';

  @override
  String get parkStatusPending => 'Pending';

  @override
  String get parkStatusActive => 'Active';

  @override
  String get endorsSnackRecorded => 'Endorsement recorded.';

  @override
  String get endorsEmpty =>
      'No manufacturer approval requests are waiting for endorsement.';

  @override
  String get endorsIntro =>
      'Confirm that the instructor is credentialed at your institution for the manufacturer\'s approval request.';

  @override
  String get endorsManufacturerFallback => 'Manufacturer';

  @override
  String endorsInstructorLine(Object name) {
    return 'Instructor: $name';
  }

  @override
  String get endorsBtnEndorse => 'Endorse';

  @override
  String get fluxRevSnackStatusUpdated => 'Status updated.';

  @override
  String get fluxRevEmpty => 'No manufacturers under review.';

  @override
  String get fluxRevQueueTitle => 'Validation queue';

  @override
  String get fluxRevIntro =>
      'Approving makes the manufacturer visible in the catalog for credentialing; rejecting or requesting information returns the flow to the manufacturer.';

  @override
  String fluxRevIdLine(Object id) {
    return 'ID $id';
  }

  @override
  String fluxRevCnpjLine(Object value) {
    return 'Tax ID: $value';
  }

  @override
  String fluxRevSupportLine(Object email) {
    return 'Support: $email';
  }

  @override
  String get fluxRevBtnRequestInfo => 'Request information';

  @override
  String get mfgLoadFailedData => 'Failed to load data.';

  @override
  String get mfgAreaTitle => 'Manufacturer';

  @override
  String get mfgNavHome => 'Home';

  @override
  String get mfgNavCompany => 'Company';

  @override
  String get mfgNavProducts => 'Products';

  @override
  String get mfgNavOperations => 'Operations';

  @override
  String get mfgNavGroupSummary => 'Summary & profile';

  @override
  String get mfgNavGroupOffer => 'Catalog & routines';

  @override
  String get mfgDashSummaryTitle => 'Aggregated summary';

  @override
  String get mfgDashSummaryIntro =>
      'Trainings and enrollments linked to this manufacturer — aggregated data (GDPR).';

  @override
  String get mfgSnackValidationRequested =>
      'Validation request sent. Our team will review it.';

  @override
  String get mfgSeasonNewTitle => 'New season';

  @override
  String get mfgFieldName => 'Name';

  @override
  String get mfgFieldSeasonStart => 'Start (YYYY-MM-DD)';

  @override
  String get mfgFieldSeasonEnd => 'End (YYYY-MM-DD)';

  @override
  String get mfgFieldTargetTrainingsOptional =>
      'Closed trainings goal (optional)';

  @override
  String get mfgBtnCancel => 'Cancel';

  @override
  String get mfgBtnClose => 'Close';

  @override
  String get mfgBtnCreate => 'Create';

  @override
  String get mfgSeasonCreatedSnack => 'Season created and ranking updated.';

  @override
  String get mfgSeasonCreateFailed => 'Could not create.';

  @override
  String get mfgSeasonRankingTitle => 'Season ranking';

  @override
  String mfgSeasonTargetLine(Object count) {
    return 'Goal: $count closed trainings';
  }

  @override
  String get mfgSeasonNoClosedTrainings =>
      'No closed trainings in this period (with this manufacturer).';

  @override
  String get mfgLeaderboardLoadFailed => 'Could not load ranking.';

  @override
  String get mfgSnackRankingRecomputed => 'Ranking recalculated.';

  @override
  String mfgPointsTrainings(Object count) {
    return '$count trainings';
  }

  @override
  String get mfgPrizeNewTitle => 'New prize (record)';

  @override
  String get mfgFieldTitle => 'Title';

  @override
  String get mfgFieldDescriptionOptional => 'Description (optional)';

  @override
  String get mfgFieldSortOptional => 'Order (optional, lower = first)';

  @override
  String get mfgBtnSave => 'Save';

  @override
  String get mfgPrizeSavedSnack => 'Prize saved.';

  @override
  String get mfgPrizeSaveFailed => 'Could not save.';

  @override
  String get mfgPrizeDeleteTitle => 'Remove prize?';

  @override
  String get mfgPrizeDeleteBody =>
      'The record will be deleted. This does not process payments (MVP).';

  @override
  String get mfgBtnAdd => 'Add';

  @override
  String get mfgBtnRemove => 'Remove';

  @override
  String get mfgSnackRemoved => 'Removed.';

  @override
  String get mfgSnackProfileUpdated => 'Profile updated.';

  @override
  String mfgSnackVersionDraftHint(Object parentId) {
    return 'Fill in the new model and tap «Add to catalog» (source #$parentId).';
  }

  @override
  String get mfgSnackNameModelRequired => 'Name and model are required.';

  @override
  String get mfgSnackEquipmentCreated => 'Equipment created.';

  @override
  String get mfgSnackNewVersionRegistered => 'New version registered.';

  @override
  String get mfgSnackFileReadError => 'Could not read the file.';

  @override
  String get mfgSnackDocumentUploaded => 'Document uploaded.';

  @override
  String get mfgSnackUploadFailed => 'Upload failed.';

  @override
  String get mfgSnackDocumentRemoved => 'Document removed.';

  @override
  String mfgSnackFileSaved(Object name) {
    return 'Saved: $name';
  }

  @override
  String get mfgSnackDownloadFailed => 'Download failed.';

  @override
  String get mfgFileFallbackName => 'File';

  @override
  String get mfgSnackOfficialTitleRequired =>
      'Enter the official training title.';

  @override
  String get mfgSnackTemplateCreated =>
      'Template created. Tap «Edit questionnaire» in the list below for official content.';

  @override
  String get mfgSeasonsSectionTitle => 'Seasons & ranking';

  @override
  String get mfgSeasonsIntro =>
      'Points = closed trainings (status «finished») linked to this manufacturer, within the season period. Daily automatic or manual update.';

  @override
  String get mfgSeasonsEmpty =>
      'No season yet — create one to track instructors by semester or cycle.';

  @override
  String mfgSeasonMetaSuffix(Object count) {
    return ' · goal $count';
  }

  @override
  String get mfgTooltipViewLeaderboard => 'View ranking';

  @override
  String get mfgTooltipRecompute => 'Recompute';

  @override
  String get mfgPrizesSectionTitle => 'Prizes (record)';

  @override
  String get mfgPrizesIntro =>
      'Informational description for campaigns or recognition — no integrated payment in MVP.';

  @override
  String get mfgPrizesEmpty => 'No prizes recorded.';

  @override
  String get mfgDocumentsSectionTitle => 'Documents for validation';

  @override
  String get mfgDocumentsIntro =>
      'PDF or image up to 12 MB. The server uses the configured disk (local or S3 via FILESYSTEM_DISK); upload manuals or attachments for approval.';

  @override
  String get mfgDocKindOptional => 'Type (optional)';

  @override
  String get mfgDocKindHint => 'e.g. manual, certificate, datasheet';

  @override
  String get mfgDocNotesOptional => 'Notes (optional)';

  @override
  String get mfgBtnSendFile => 'Send file';

  @override
  String get mfgDocumentsEmpty => 'No documents uploaded.';

  @override
  String get mfgTooltipDownload => 'Download';

  @override
  String get mfgOfficialTrainingTitle => 'Official trainings (templates)';

  @override
  String get mfgOfficialTrainingIntro =>
      'Templates without institution; credentialed instructors instantiate them for the hospital.';

  @override
  String get mfgTemplateTitleLabel => 'Template title';

  @override
  String get mfgTemplateTitleHint => 'e.g. Basic operation of ventilator X';

  @override
  String get mfgBtnCreateTemplateDraft => 'Create template (draft)';

  @override
  String get mfgYourTemplates => 'Your templates';

  @override
  String get mfgTemplatesEmpty => 'No templates yet. Create one above.';

  @override
  String get mfgTrainingFallbackTitle => 'Training';

  @override
  String get mfgBtnEditQuestionnaire => 'Edit questionnaire';

  @override
  String get mfgCompanySectionTitle => 'Company';

  @override
  String get mfgFieldSupportEmail => 'Support email';

  @override
  String get mfgLabelCnpj => 'Tax ID';

  @override
  String get mfgBtnSaveProfile => 'Save profile';

  @override
  String get mfgCatalogSectionTitle => 'Catalog (approvals)';

  @override
  String get mfgCatalogIntro =>
      'Equipment here has no institution — visible for building trainings. With derived versions, the original record can no longer be edited.';

  @override
  String mfgNewVersionFromRecord(Object id) {
    return 'New version from record #$id';
  }

  @override
  String get mfgFieldEquipmentName => 'Equipment name';

  @override
  String get mfgFieldModel => 'Model';

  @override
  String get mfgFieldSectorOptionalCatalog => 'Sector (optional)';

  @override
  String get mfgCategoryOptionalLabel => 'Category (optional)';

  @override
  String get mfgBtnAddToCatalog => 'Add to catalog';

  @override
  String get mfgFilterListLabel => 'Filter list';

  @override
  String get mfgEquipmentEmpty => 'No equipment yet.';

  @override
  String mfgEquipmentDerivedFrom(Object parentId, Object model) {
    return 'Derived version from #$parentId · $model';
  }

  @override
  String get mfgBtnNewVersion => 'New version';

  @override
  String get mfgValidationTitle => 'Manufacturer credentialing';

  @override
  String mfgValidationStateLine(Object status) {
    return 'Status: $status';
  }

  @override
  String get mfgFlowStepCompany => 'Company data';

  @override
  String get mfgFlowStepFluxxoReview => 'Platform review';

  @override
  String get mfgFlowStepHomologation => 'Approval';

  @override
  String get mfgValStatusPendingInfo => 'Information pending';

  @override
  String get mfgValStatusPendingValidation => 'Under review by the team';

  @override
  String get mfgValStatusActive => 'Active on the credentialed network';

  @override
  String get mfgValStatusRejected => 'Validation rejected';

  @override
  String get mfgValHelpPendingInfo =>
      'Complete company data and submit for validation. You can attach supporting documents under Operations → Documents.';

  @override
  String get mfgValHelpPendingValidation =>
      'Your request is in the review queue. Official templates can still be edited; visibility in the instructor catalog follows network rules.';

  @override
  String get mfgValHelpActive =>
      'The manufacturer is approved on the network. Instructors can request credentialing with this manufacturer and use official templates in the catalog.';

  @override
  String get mfgValHelpRejected =>
      'Adjust the data or documentation indicated by the team and submit again.';

  @override
  String get mfgValHelpDefault =>
      'Manufacturer credentialing status on the platform.';

  @override
  String get mfgBtnSubmitForReview => 'Submit for review';

  @override
  String get mfgBtnResubmitForReview => 'Submit again for review';

  @override
  String get trnSnackSectorRequired => 'Enter your sector.';

  @override
  String get trnSnackCodeRequired => 'Enter the access code.';

  @override
  String get trnSnackSessionPaused =>
      'The session is paused. Wait for the instructor to resume.';

  @override
  String get trnSnackPickOption => 'Select an option.';

  @override
  String get trnSnackLgpdCheckbox =>
      'Check the box to confirm you have read and agree.';

  @override
  String get trnSnackJsonCopied => 'Data copied to the clipboard (JSON).';

  @override
  String get trnSnackCancelled => 'Cancelled.';

  @override
  String get trnSnackFormOpenFailed => 'Could not open the form.';

  @override
  String trnSnackFollowUpAvailableFrom(Object due) {
    return 'Available from $due.';
  }

  @override
  String get trnSnackFollowUpNotYet => 'You cannot answer yet.';

  @override
  String get trnSnackResponsesSaved => 'Responses saved.';

  @override
  String get trnSnackCertPdfDownloaded => 'Certificate PDF downloaded.';

  @override
  String get trnSnackCertPdfFailed => 'Could not download the PDF.';

  @override
  String get trnSnackPickInstitution =>
      'Select an institution in pre-registration.';

  @override
  String get trnSnackPickReason => 'Choose a reason for the request.';

  @override
  String get trnSnackRequestSent => 'Request sent to the institution.';

  @override
  String get trnDeleteAccountTitle => 'Delete account';

  @override
  String get trnDeleteAccountBodyGoogle =>
      'This irreversibly anonymizes your account (Art. 18 LGPD). Confirm with DELETE and authenticate again with Google.';

  @override
  String get trnDeleteAccountBodyPassword =>
      'This irreversibly anonymizes your account (Art. 18 LGPD). Type DELETE in uppercase and your password.';

  @override
  String get trnFieldPassword => 'Password';

  @override
  String get trnFieldConfirmDelete => 'Confirm (type DELETE)';

  @override
  String get trnBtnConfirm => 'Confirm';

  @override
  String get trnApiOk => 'API ok';

  @override
  String get trnApiOffline => 'No API';

  @override
  String get trnTooltipPrivacy => 'Privacy';

  @override
  String get trnMenuExportJson => 'Export my data (JSON)';

  @override
  String get trnMenuDeleteAccount => 'Delete my account';

  @override
  String get trnTooltipSignOut => 'Sign out';

  @override
  String get trnPrivacyTitle => 'Privacy and data';

  @override
  String get trnLgpdIntro =>
      'Before training, we need your explicit consent (LGPD — Law 13.709/2018):';

  @override
  String get trnLgpdBullets =>
      '• Purpose: identification in trainings, certificates, and aggregated institution reports.\n• Sharing: individual data only with the instructor during the session; to the institution, in aggregated form.\n• Retention: up to 5 years after the last training for audit, unless you request deletion or anonymization.\n• Rights: access, correction, portability, and deletion via the Privacy menu (icon at the top).\n• Google: when using Google login, data is also processed under Google’s policy.';

  @override
  String get trnLgpdCheckboxTitle =>
      'I have read and agree to the processing of my personal data under the App²cation Privacy Policy.';

  @override
  String get trnBtnContinue => 'Continue';

  @override
  String get trnPreregTitle => 'Pre-registration';

  @override
  String get trnPreregSubtitle => 'Real data saved to your account.';

  @override
  String get trnFieldInstitutionOptional => 'Institution (optional)';

  @override
  String get trnFieldSectorTeam => 'Sector / team *';

  @override
  String get trnFieldEquipmentContext => 'Equipment / context';

  @override
  String get trnFieldSessionAtOptional => 'Session date and time (optional)';

  @override
  String get trnHintDatetime => 'YYYY-MM-DD HH:MM';

  @override
  String get trnBtnSaveContinue => 'Save and continue';

  @override
  String get trnCertificatesTitle => 'Certificates';

  @override
  String get trnCertificatesEmpty =>
      'No certificates yet — complete a training with score ≥ minimum.';

  @override
  String trnCertScoreValid(Object score, Object expires) {
    return 'Score $score · valid until $expires';
  }

  @override
  String get trnFollowUpsTitle => 'Post-training follow-ups';

  @override
  String get trnFollowUpsIntro =>
      'Short questionnaires (e.g. 10, 15 and 30 days after completion), per training settings.';

  @override
  String get trnFollowUpsEmpty => 'No follow-up scheduled.';

  @override
  String trnFollowUpListSubtitle(Object days, Object status, Object due) {
    return 'Day +$days · $status · due $due';
  }

  @override
  String get trnTrainingRequestTitle => 'Training request (institution)';

  @override
  String get trnTrainingRequestIntro =>
      'Standardized reason, priority, and preferred dates for the request.';

  @override
  String get trnLoadingOptions => 'Loading options…';

  @override
  String get trnFieldReason => 'Reason';

  @override
  String get trnFieldPriority => 'Priority';

  @override
  String get trnFieldParkUnitOptional => 'Park unit (optional)';

  @override
  String get trnParkUnitHelper =>
      'List from the institution in your pre-registration.';

  @override
  String get trnParkEmptyHint =>
      'No units in the park, or complete pre-registration with an institution to load the park.';

  @override
  String get trnFieldPreferredDate => 'Preferred date (optional)';

  @override
  String get trnHintDate => 'YYYY-MM-DD';

  @override
  String get trnFieldLatestAcceptable => 'Latest acceptable date (optional)';

  @override
  String get trnFieldNotesOptional => 'Notes (optional)';

  @override
  String get trnNotesHint => 'Location, shift, contact…';

  @override
  String get trnBtnSendRequest => 'Send request';

  @override
  String get trnMyRequests => 'My requests';

  @override
  String get trnJoinTitle => 'Join training';

  @override
  String get trnJoinIntro => 'Use the code provided by the instructor.';

  @override
  String get trnFieldAccessCode => 'Access code';

  @override
  String get trnBtnConfirmJoin => 'Confirm entry';

  @override
  String get trnWaitingRoomTitle => 'Waiting room';

  @override
  String get trnWaitingRoomBody =>
      'As soon as the instructor starts, the questionnaire opens automatically.';

  @override
  String get trnWaitingHeroTitle => 'Waiting for training to start';

  @override
  String get trnWaitingHeroBody =>
      'The instructor will start the session shortly. Keep this window open to join the virtual room automatically.';

  @override
  String get trnWaitingStatusChip => 'Status: waiting room active';

  @override
  String get trnWaitingTestConnection => 'Test connection and devices';

  @override
  String get trnWaitingPingOk => 'Server connection OK.';

  @override
  String get trnWaitingPingFail => 'Could not reach the server.';

  @override
  String get trnWaitingPrivacyNote =>
      'Camera and microphone stay off by default in this version.';

  @override
  String get trnHeaderWaitingInstructor => 'Awaiting instructor';

  @override
  String get trnHeaderRealtimeActive => 'Realtime: active';

  @override
  String get trnQuestionSidebarNavTitle => 'Navigation';

  @override
  String get trnEmptyRecoverySync =>
      'Syncing recovery or finishing the training…';

  @override
  String get trnEmptyNoQuestions => 'No questions available.';

  @override
  String get trnPausedSessionBanner =>
      'Session paused. You cannot answer until the instructor resumes.';

  @override
  String get trnRecoveryBanner =>
      'Recovery: only questions the instructor released for another attempt.';

  @override
  String get trnProgressLabel => 'PROGRESS';

  @override
  String trnQuestionProgress(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String get trnBtnConfirmAnswer => 'Confirm answer';

  @override
  String get trnBtnSubmitResponses => 'Submit responses';

  @override
  String get trnOptionalHint => 'Optional';

  @override
  String get trnResultTitle => 'Training completed';

  @override
  String get trnScoreLabel => 'Score (0–10)';

  @override
  String get trnBtnJoinAnother => 'Join another training';

  @override
  String get trnFollowUpDialogTitle => 'Post-training follow-up';

  @override
  String get trnTrainingDefaultTitle => 'Training';

  @override
  String trnRequestListPark(Object detail) {
    return 'Park: $detail';
  }

  @override
  String trnRequestListPref(Object date) {
    return 'pref. $date';
  }

  @override
  String trnRequestListLimit(Object date) {
    return 'limit $date';
  }

  @override
  String get trnFollowUpRespond => 'Answer';

  @override
  String get trnTooltipCertPdf => 'Download PDF';

  @override
  String get mfgTplIntro =>
      'Blocks and questions follow the same format as operational trainings. Accredited instructors clone this content.';

  @override
  String get mfgTplSectionQuestions => 'Questions';

  @override
  String get mfgTplBtnAddQuestion => 'Question';

  @override
  String get mfgTplSnackSaved => 'Questionnaire saved.';

  @override
  String get mfgTplErrNeedCorrect =>
      'Each question must have one correct option.';

  @override
  String get mfgTplErrMinQuestions =>
      'Add at least one question with two or more options.';

  @override
  String mfgTplQuestionNumber(Object n) {
    return 'Question $n';
  }

  @override
  String get mfgTplFieldPrompt => 'Prompt';

  @override
  String get mfgTplOptionsHint => 'Options (mark the correct one)';

  @override
  String mfgTplOptionNumber(Object n) {
    return 'Option $n';
  }

  @override
  String get mfgTplBtnSaveApi => 'Save questionnaire to API';

  @override
  String get mfgTplOfficialBlockTitle => 'Official content';

  @override
  String get fluxPanelTraineeTitle => 'Trainee journey';

  @override
  String get fluxPanelTraineeSubtitle =>
      'Aligned with the spec: pre-registration → join → GDPR consent → live session → result.';

  @override
  String get fluxPanelTraineeS1Label => 'Profile and clinical context';

  @override
  String get fluxPanelTraineeS1Detail =>
      'Sector, equipment and institution when applicable.';

  @override
  String get fluxPanelTraineeS2Label => 'Join the session';

  @override
  String get fluxPanelTraineeS2Detail =>
      'Code or hash provided by your instructor or institution.';

  @override
  String get fluxPanelTraineeS3Label => 'LGPD consent';

  @override
  String get fluxPanelTraineeS3Detail =>
      'Required before answering the questionnaire.';

  @override
  String get fluxPanelTraineeS4Label => 'Waiting room and live session';

  @override
  String get fluxPanelTraineeS4Detail =>
      'Wait for the instructor to start; blocks released in order.';

  @override
  String get fluxPanelTraineeS5Label => 'Answers and result';

  @override
  String get fluxPanelTraineeS5Detail =>
      'Immediate feedback; approval according to training rules (e.g. ≥70%).';

  @override
  String get fluxPanelInstructorTitle => 'Instructor journey';

  @override
  String get fluxPanelInstructorSubtitle =>
      'Dual credentialing (institution + manufacturer when applicable), session creation and real-time command center.';

  @override
  String get fluxPanelInstructorS1Label => 'Credentialing';

  @override
  String get fluxPanelInstructorS1Detail =>
      'Institution and catalogue under the Credentialing tab.';

  @override
  String get fluxPanelInstructorS2Label => 'Create training and questionnaire';

  @override
  String get fluxPanelInstructorS2Detail =>
      'Trainings, blocks and questions aligned with equipment.';

  @override
  String get fluxPanelInstructorS3Label => 'Command room';

  @override
  String get fluxPanelInstructorS3Detail =>
      'Start session, release blocks, retakes and closing.';

  @override
  String get fluxPanelInstructorS4Label => 'Participants and monitoring';

  @override
  String get fluxPanelInstructorS4Detail =>
      'Roster and progress during the session.';

  @override
  String get fluxPanelInstitutionTitle => 'Institution journey';

  @override
  String get fluxPanelInstitutionSubtitle =>
      'Fleet management, instructor links and organisation-wide training visibility.';

  @override
  String get fluxPanelInstitutionS1Label => 'Registration and institutions';

  @override
  String get fluxPanelInstitutionS1Detail =>
      'Keep institution data and required links up to date.';

  @override
  String get fluxPanelInstitutionS2Label => 'Technology fleet';

  @override
  String get fluxPanelInstitutionS2Detail =>
      'Declare equipment in use (ongoing product evolution).';

  @override
  String get fluxPanelInstitutionS3Label => 'Institution instructors';

  @override
  String get fluxPanelInstitutionS3Detail =>
      'Coordinate who delivers training in your spaces.';

  @override
  String get fluxPanelInstitutionS4Label => 'Aggregated indicators';

  @override
  String get fluxPanelInstitutionS4Detail =>
      'By sector, GDPR-compliant (no individual identification).';

  @override
  String get fluxPanelManufacturerTitle => 'Manufacturer journey';

  @override
  String get fluxPanelManufacturerSubtitle =>
      'Owner of technical knowledge: catalogue, official content and accredited instructor network.';

  @override
  String get fluxPanelManufacturerS1Label => 'Company profile';

  @override
  String get fluxPanelManufacturerS1Detail =>
      'Corporate data and support contact.';

  @override
  String get fluxPanelManufacturerS2Label => 'Equipment catalogue';

  @override
  String get fluxPanelManufacturerS2Detail =>
      'Approved models for training and institutions.';

  @override
  String get fluxPanelManufacturerS3Label => 'Official training bank';

  @override
  String get fluxPanelManufacturerS3Detail =>
      'Standard questionnaires per equipment.';

  @override
  String get fluxPanelManufacturerS4Label => 'Instructor accreditation';

  @override
  String get fluxPanelManufacturerS4Detail =>
      'Fee and validation of the Application network.';

  @override
  String get fluxPanelManufacturerS5Label => 'Analytics and gamification';

  @override
  String get fluxPanelManufacturerS5Detail =>
      'Aggregated performance and rankings.';

  @override
  String get fluxPanelWeeklyTitle => 'Weekly email digest';

  @override
  String get fluxPanelWeeklySubtitle =>
      'Aggregated indicators (GDPR), Monday mornings. You can turn this off here.';

  @override
  String get fluxPanelPrefSaveFailed => 'Could not save preference.';

  @override
  String get fluxPanelRoadmapBadge => 'roadmap';

  @override
  String errApiNetworkUnreachable(Object detail) {
    return 'Could not reach the server. Check your network and API URL. ($detail)';
  }

  @override
  String errApiInvalidHttpBody(Object code) {
    return 'Invalid server response (HTTP $code).';
  }

  @override
  String get errApiResponseNotList => 'Response is not a list.';

  @override
  String get errApiOperationIncomplete => 'Could not complete the operation.';

  @override
  String get errApiUploadMissingFileSource =>
      'Choose a file or provide file data for the upload.';

  @override
  String get errAuthInvalidLoginResponse => 'Invalid login response.';

  @override
  String get errAuthInvalidRegisterResponse => 'Invalid sign-up response.';

  @override
  String get errAuthGoogleCancelled => 'Google sign-in was cancelled.';

  @override
  String get errAuthInvalidGoogleLoginResponse =>
      'Invalid Google sign-in response.';

  @override
  String get errGoogleNoIdToken =>
      'Google did not return an id_token. Check the Web client ID and APIs in Google Cloud.';

  @override
  String errGoogleSignInFailed(Object detail) {
    return 'Google sign-in failed: $detail';
  }

  @override
  String loginDebugApiLine(Object url) {
    return 'API: $url';
  }

  @override
  String mfgDocSizeBytes(Object size) {
    return '$size B';
  }

  @override
  String mfgDocSizeKb(Object size) {
    return '$size KB';
  }

  @override
  String mfgDocSizeMb(Object size) {
    return '$size MB';
  }

  @override
  String get trnCertCodeFallback => 'certificate';

  @override
  String trnCertDownloadFilename(Object code) {
    return 'certificate-$code';
  }

  @override
  String dashExportFileInstitutionCsv(Object stamp) {
    return 'appcation-institution-$stamp.csv';
  }

  @override
  String dashExportFileInstitutionPdf(Object stamp) {
    return 'appcation-institution-$stamp.pdf';
  }

  @override
  String dashExportFileManufacturerCsv(Object stamp) {
    return 'appcation-manufacturer-$stamp.csv';
  }

  @override
  String dashExportFileManufacturerPdf(Object stamp) {
    return 'appcation-manufacturer-$stamp.pdf';
  }

  @override
  String get utilDownloadWebOnly =>
      'File download is only available in the web app.';
}
