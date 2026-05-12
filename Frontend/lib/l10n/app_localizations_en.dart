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
  String get loginAccessHeroSubtitle =>
      'Training management platform for hospital equipment';

  @override
  String get loginCardSignInHeadline => 'Sign in to your account';

  @override
  String get loginCardSignInLead =>
      'Use your account or institutional email and password.';

  @override
  String get loginUrsSecurePortalSubtitle => 'Secure portal access';

  @override
  String get loginSectionLoginTitle => 'Login';

  @override
  String get loginInstitutionalCredentialsTitle => 'Credentials (email)';

  @override
  String get loginPasswordOnlyHint =>
      'Sign-in is email and password. If you do not have a profile yet, you will be asked to choose an account type after your first login.';

  @override
  String get loginFieldIdentifier => 'Identifier';

  @override
  String get loginFieldIdentifierHint =>
      'CPF, CRM, CNPJ, or institutional email';

  @override
  String get loginIdentityPatient => 'Profile: trainee (valid CPF)';

  @override
  String get loginIdentityInstitution =>
      'Profile: institution / manufacturer (CNPJ)';

  @override
  String get loginIdentityDoctor => 'Profile: instructor (CRM)';

  @override
  String get loginIdentitySystem => 'Internal account (alphanumeric login)';

  @override
  String get loginIdentityEmail => 'Institutional email';

  @override
  String get loginIdentityUnknown =>
      'Unrecognized identifier — use a valid email registered on the platform.';

  @override
  String get loginForgotPassword => 'Forgot password';

  @override
  String get loginNoAccountPrefix => 'No account?';

  @override
  String get loginNoAccountAction => 'Create account';

  @override
  String get loginUrsHeroTagline =>
      'Connecting care and technology in real time';

  @override
  String get loginEmptyIdentifierPassword => 'Identifier or password is empty.';

  @override
  String get loginIdentifierInvalidClient =>
      'Invalid identifier. Use a valid CPF, CRM, CNPJ, admin login, or email.';

  @override
  String get loginPasswordRequiresEmail =>
      'Password sign-in requires your account email.';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

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
  String get registerMfgCompanyOptionalDomain =>
      'Required only for the first signup on this domain; leave blank to join an existing manufacturer.';

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
  String get shellNavPostTrainingResults => 'Training results';

  @override
  String get shellTitlePostTrainingResults => 'Results and recovery';

  @override
  String get postTrainingIntro =>
      'After the session, review participants, run recovery for those who need it, and finalize when everyone is assessed. Live control stays in the Command room.';

  @override
  String get postTrainingPickTraining =>
      'Pick a training to load enrolled participants.';

  @override
  String get postTrainingOutcomeApproved => 'Passed (≥ 7.0)';

  @override
  String get postTrainingOutcomeInsufficient => 'Below threshold (< 7.0)';

  @override
  String get postTrainingOutcomeRecovery => 'In recovery';

  @override
  String get postTrainingOutcomeInProgress => 'In progress';

  @override
  String get postTrainingOutcomeWaitingRoom => 'Waiting room';

  @override
  String get postTrainingOutcomeCompletedNoGrade => 'Completed (no score)';

  @override
  String get postTrainingFinishTraining => 'Close training';

  @override
  String get postTrainingFinishTrainingConfirmTitle => 'Close this training?';

  @override
  String get postTrainingFinishTrainingConfirmBody =>
      'Status becomes finished. Trainees can no longer answer the questionnaire in this session.';

  @override
  String get postTrainingFinishTrainingDone =>
      'Training closed. Certificates ensured for everyone at or above the passing score.';

  @override
  String get postTrainingCertificatePdfTooltip => 'Download certificate (PDF)';

  @override
  String get postTrainingIssueCertificate => 'Issue certificate';

  @override
  String get postTrainingIssueCertificateTooltip =>
      'Register the certificate when the score already meets the passing threshold (e.g. after a missed close step).';

  @override
  String get postTrainingIssueCertificateDone => 'Certificate issued.';

  @override
  String get postTrainingIssueCertificateAlready =>
      'This participant already had a certificate.';

  @override
  String get postTrainingExportCertificatesCsvTooltip =>
      'Download a CSV of enrollments and certificates for this training (audit).';

  @override
  String get postTrainingExportCertificatesDone => 'CSV report downloaded.';

  @override
  String postTrainingExportCertificatesCsvFilename(
    int trainingId,
    String stamp,
  ) {
    return 'appcation-training-$trainingId-$stamp.csv';
  }

  @override
  String get postTrainingExportCertificatesPdfTooltip =>
      'Download a PDF of enrollments and certificates for this training (audit).';

  @override
  String get postTrainingExportCertificatesPdfDone => 'PDF report downloaded.';

  @override
  String postTrainingExportCertificatesPdfFilename(
    int trainingId,
    String stamp,
  ) {
    return 'appcation-training-$trainingId-$stamp.pdf';
  }

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
  String get profileGateTitle => 'Unrecognized profile';

  @override
  String get profileGateBody =>
      'You are signed in, but this account has no role mapped to an app area (trainee, instructor, institution manager, or manufacturer). Sign out and sign in again; on first access, choose the correct account type when prompted.';

  @override
  String get profileGateDocHint =>
      'Official product flow: docs/product/fluxo_app2cation.mermaid';

  @override
  String get profileGateYourAccount => 'Signed-in account';

  @override
  String profileGateRoleFromApi(Object role) {
    return 'Role from server: $role';
  }

  @override
  String get profileGateClaimSectionTitle => 'Set profile (one time)';

  @override
  String get profileGateClaimIntro =>
      'If your account should be a trainee, instructor, or manufacturer admin but the server role was missing or invalid, choose it below. This is allowed only until a valid role is stored.';

  @override
  String get profileGateClaimHint =>
      'Institution managers are not self-service here — your hospital or manufacturer creates that access.';

  @override
  String get profileGateChooseRole => 'Platform role';

  @override
  String get profileGateConfirmProfile => 'Confirm profile';

  @override
  String get profileGatePickRoleFirst => 'Choose a role first.';

  @override
  String get profileGateRetryLaterOrSignOut =>
      'Could not sync right now. Try again in a moment or sign out and sign back in.';

  @override
  String get loginGoogleTriageHint =>
      'If you do not have a profile yet, after signing in you will choose your profile in two steps (and company details if needed).';

  @override
  String get profileTriageTitle => 'Choose your profile';

  @override
  String get profileTriageSubtitle =>
      'Select the account type. On the next step you confirm or complete details to activate your profile on the platform.';

  @override
  String get profileTriageStep2Title => 'Profile details';

  @override
  String get profileTriageTraineeBody =>
      'As a trainee you join sessions with a code, answer questionnaires, and access certificates.';

  @override
  String get profileTriageInstructorBody =>
      'As an instructor you create and run trainings and get credentialed with institutions and manufacturers when applicable.';

  @override
  String get profileTriageManufacturerBody =>
      'Enter the public company name and optionally the tax ID. Your email domain determines the manufacturer area.';

  @override
  String get profileTriageBack => 'Change profile type';

  @override
  String get actionRetry => 'Try again';

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
  String get dashInstitutionAlertPendingTitle => 'Requests to review';

  @override
  String dashInstitutionAlertPendingBody(int count) {
    return 'There are $count pending training request(s) in the queue. Open the board to review and schedule.';
  }

  @override
  String get dashInstitutionShortcutsTitle => 'Manager areas';

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
  String get dashSectorAveragesTitle => 'By sector (institution trainings)';

  @override
  String get dashNoSectorHistory => 'No sector history yet.';

  @override
  String dashSectorSubtitle(int total, int done, int scored, String avg) {
    return 'Enrollments: $total · Completed: $done · With score: $scored · Average: $avg';
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
  String get trainLifecycleCancelled => 'Cancelled';

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
  String get comandoParticipantsSearchHint => 'Filter by name or email';

  @override
  String get comandoParticipantsNoMatch => 'No participants match this filter.';

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
  String get comandoOfflineHint =>
      'Cannot reach the server. Session commands stay unavailable until the API is back; you can refresh the training list when online.';

  @override
  String get instrOfflineHint =>
      'Cannot reach the server. Refresh when back online; save and export actions stay disabled until the API responds.';

  @override
  String comandoParticipantAnswers(
    Object answered,
    Object total,
    Object status,
  ) {
    return 'Answers $answered / $total · $status';
  }

  @override
  String get comandoHeroTitle => 'Live execution';

  @override
  String get comandoHeroLiveBadge => 'Live';

  @override
  String get comandoHeroModulePrefix => 'Module:';

  @override
  String get comandoStatDurationLabel => 'Duration';

  @override
  String get comandoStatParticipantsLabel => 'Participants';

  @override
  String get comandoStatActiveShort => 'Active';

  @override
  String get comandoStatWaitingShort => 'Waiting';

  @override
  String get comandoDurationPlaceholder => '—';

  @override
  String get comandoProgressByBlockTitle => 'Progress by block';

  @override
  String get comandoColBlockTitle => 'Block';

  @override
  String get comandoColState => 'Status';

  @override
  String get comandoColCompletion => 'Completion';

  @override
  String get comandoColAccuracy => 'Accuracy';

  @override
  String get comandoBlockStateReleased => 'Released';

  @override
  String get comandoBlockStatePending => 'Pending';

  @override
  String get comandoDeckSubtitle =>
      'Start, pause, or end the session in real time.';

  @override
  String get comandoDeckBadgeRunning => 'Running';

  @override
  String get comandoDeckBadgePaused => 'Paused';

  @override
  String get comandoDeckBadgeScheduled => 'Scheduled';

  @override
  String get comandoDeckBadgeFinished => 'Ended';

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
  String get credBtnSuspend => 'Suspend';

  @override
  String get credBtnReactivateHomolog => 'Reactivate';

  @override
  String get credStatusSuspended => 'Suspended';

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
  String get trainReqKanbanColumnQueue => 'Queue';

  @override
  String get trainReqKanbanColumnQueueHint => 'Pending · Approved';

  @override
  String get trainReqKanbanColumnScheduled => 'Scheduled';

  @override
  String get trainReqKanbanColumnScheduledHint => 'With an assigned instructor';

  @override
  String get trainReqKanbanColumnClosed => 'Closed';

  @override
  String get trainReqKanbanColumnClosedHint => 'Completed · Rejected';

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
  String get trainReqBatchCheckboxLabel => 'Select for batch scheduling';

  @override
  String trainReqBatchToolbarSelected(int count) {
    return '$count selected';
  }

  @override
  String get trainReqBatchToolbarClear => 'Clear selection';

  @override
  String get trainReqBatchToolbarSchedule => 'Schedule in batch';

  @override
  String get trainReqBatchDialogTitle => 'Batch schedule requests';

  @override
  String trainReqBatchDialogBody(int count) {
    return 'Pick the instructor for $count request(s) in the queue (pending or approved).';
  }

  @override
  String get trainReqBatchSelectInstructorPlaceholder =>
      'Choose an instructor…';

  @override
  String get trainReqBatchConfirm => 'Schedule';

  @override
  String trainReqBatchSnackDone(int count) {
    return 'Scheduled $count request(s).';
  }

  @override
  String get trainReqBatchSnackNoneEligible =>
      'No eligible requests in the selection (use pending or approved in the queue).';

  @override
  String get trainReqBatchNoInstructors =>
      'No credentialed instructors yet — approve credentials first.';

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
  String get parkSearchHint =>
      'Search name, model, sector, or manufacturer (catalog)';

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
  String get mfgNavHomologations => 'Credentialing';

  @override
  String get mfgNavAnalytics => 'Analytics';

  @override
  String get mfgAnalyticsTitle => 'Aggregated analytics';

  @override
  String get mfgAnalyticsIntro =>
      'Filter by institution, equipment on the training, or training creation period. Aggregated data only (GDPR).';

  @override
  String get mfgAnalyticsFilterInstitution => 'Institution';

  @override
  String get mfgAnalyticsFilterEquipment => 'Equipment (on training)';

  @override
  String get mfgAnalyticsDateFrom => 'Trainings created from (YYYY-MM-DD)';

  @override
  String get mfgAnalyticsDateTo => 'Trainings created to (YYYY-MM-DD)';

  @override
  String get mfgAnalyticsApply => 'Apply filters';

  @override
  String get mfgAnalyticsReset => 'Clear';

  @override
  String get mfgAnalyticsAll => 'All';

  @override
  String get mfgAnalyticsSectionInstitutions => 'By institution';

  @override
  String get mfgAnalyticsSectionEquipment => 'By equipment';

  @override
  String get mfgAnalyticsEmpty => 'No data for these filters.';

  @override
  String get mfgAnalyticsLoading => 'Loading…';

  @override
  String mfgAnalyticsBreakdownSubtitle(
    int trainings,
    int enr,
    int done,
    String rate,
    String avg,
  ) {
    return '$trainings trainings · enroll.: $enr · compl.: $done · rate: $rate · avg.: $avg';
  }

  @override
  String get mfgAnalyticsSectionMonthlyTrend => 'Monthly trend (combined)';

  @override
  String get mfgAnalyticsMonthlyTrendIntro =>
      'Same timeline (YYYY-MM): enrollments by COALESCE(joined_at, created_at) and completions by completed_at (UTC). Bars scaled to each metric’s max.';

  @override
  String get mfgAnalyticsMonthlyTrendEmpty =>
      'No monthly data in the filtered period.';

  @override
  String get mfgAnalyticsTrendLegendEnroll => 'Enrollments';

  @override
  String get mfgAnalyticsTrendLegendComplete => 'Completed';

  @override
  String mfgHomologRequestedAt(String date) {
    return 'Submitted: $date';
  }

  @override
  String get mfgHomologEmpty => 'No credential requests at the moment.';

  @override
  String get mfgHomologFilterAll => 'All';

  @override
  String get mfgHomologFilterPending => 'Pending';

  @override
  String get mfgHomologFilterApproved => 'Approved';

  @override
  String get mfgHomologFilterRejected => 'Rejected';

  @override
  String get mfgHomologFilterSuspended => 'Suspended';

  @override
  String get mfgSnackHomologUpdated => 'Credential request updated.';

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
  String get mfgDashMonthlyTrendTitle => 'Recent trend (monthly)';

  @override
  String get mfgDashMonthlyTrendIntro =>
      'Up to the last 6 months with data: enrollments vs. completions (same logic as Analytics).';

  @override
  String get mfgDashOpenAnalytics => 'Open analytics';

  @override
  String get mfgDashSummaryUnavailableTitle => 'Aggregated summary unavailable';

  @override
  String get mfgDashSummaryUnavailableBody =>
      'Could not load the summary right now. Try again or open Analytics.';

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
  String get mfgOpsSearchHint =>
      'Search seasons, prizes, and uploaded documents';

  @override
  String get mfgOpsServerFilterHint =>
      'Server-side filter; results refresh shortly after you stop typing.';

  @override
  String get mfgOpsSublistNoMatch => 'No matches in this block.';

  @override
  String get mfgOpsLoadMore => 'Load more';

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
  String get mfgTplSearchHint => 'Search template title';

  @override
  String get mfgTplFilterStatusLabel => 'Template status';

  @override
  String get mfgTplSortLabel => 'Sort list';

  @override
  String get mfgTplSortUpdated => 'Recently updated';

  @override
  String get mfgTplSortTitleAsc => 'Title (A–Z)';

  @override
  String get mfgTplSortTitleDesc => 'Title (Z–A)';

  @override
  String get mfgTplSortStatus => 'By status';

  @override
  String mfgTplRowUpdatedAt(String date) {
    return 'Updated: $date';
  }

  @override
  String mfgTplListResultCount(Object count) {
    return '$count template(s) listed (up to 80).';
  }

  @override
  String get mfgTplClearFilters => 'Clear filters';

  @override
  String get mfgTplNoMatches => 'No templates match the current filters.';

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
  String get mfgDashQuickCatalogTitle => 'Catalog equipment';

  @override
  String get mfgDashQuickCatalogBody =>
      'Register model, documentation, and training defaults in a two-step flow.';

  @override
  String get mfgDashNewEquipment => 'New equipment';

  @override
  String get mfgEquipWizardTitle => 'New equipment';

  @override
  String get mfgEquipWizardEditTitle => 'Edit equipment';

  @override
  String get mfgEquipWizardSaveChanges => 'Save changes';

  @override
  String get mfgBtnEditEquipment => 'Edit';

  @override
  String get mfgEquipWizardStep1 => 'Identification & specs';

  @override
  String get mfgEquipWizardStep2 => 'Training defaults & files';

  @override
  String get mfgEquipWizardNext => 'Next';

  @override
  String get mfgEquipWizardBack => 'Back';

  @override
  String get mfgEquipWizardSubmit => 'Save';

  @override
  String get mfgEquipErrInvalidInteger =>
      'Use whole numbers in optional numeric fields.';

  @override
  String get mfgEquipErrHoursRange =>
      'Training hours must be between 1 and 999.';

  @override
  String get mfgEquipErrPassRange =>
      'Passing score must be between 40 and 100.';

  @override
  String get mfgEquipErrCertMonthsRange =>
      'Certificate validity must be between 1 and 240 months.';

  @override
  String get mfgEquipErrReassessRange =>
      'Reassessment days must be between 1 and 365.';

  @override
  String get mfgEquipErrQuantityRange =>
      'Quantity must be at least 1 when provided.';

  @override
  String get mfgEquipFieldFirmware => 'Firmware version';

  @override
  String get mfgEquipFieldSerial => 'Serial number';

  @override
  String get mfgEquipCategoryRequired => 'Category *';

  @override
  String get mfgEquipSnackCategoryRequired =>
      'Choose a category for the root equipment record.';

  @override
  String get mfgEquipSpecsTitle => 'Technical attributes (optional)';

  @override
  String get mfgEquipSpecLabel => 'Label';

  @override
  String get mfgEquipSpecValue => 'Value';

  @override
  String get mfgEquipAddSpecRow => 'Add row';

  @override
  String get mfgEquipFieldIntroVideoUrl => 'Intro video URL (optional)';

  @override
  String get mfgEquipDefaultsTitle => 'Training defaults (optional)';

  @override
  String get mfgEquipDefaultsRangeHint =>
      'When filled: hours 1–999, score 40–100 %, certificate 1–240 months, reassessment 1–365 days, quantity ≥ 1.';

  @override
  String get mfgEquipHelperHours => 'Optional · whole number · 1–999';

  @override
  String get mfgEquipHelperPass => 'Optional · whole number · 40–100';

  @override
  String get mfgEquipHelperCertMonths => 'Optional · whole number · 1–240';

  @override
  String get mfgEquipHelperReassess => 'Optional · whole number · 1–365';

  @override
  String get mfgEquipHelperQuantity => 'Optional · whole number · ≥ 1';

  @override
  String get mfgEquipDefaultTrainingHours => 'Training hours';

  @override
  String get mfgEquipDefaultPassingScore => 'Passing score (%)';

  @override
  String get mfgEquipDefaultCertMonths => 'Certificate validity (months)';

  @override
  String get mfgEquipDefaultReassessmentDays => 'Reassessment (days)';

  @override
  String get mfgEquipFieldQuantity => 'Quantity';

  @override
  String get mfgEquipFieldStatus => 'Status';

  @override
  String get mfgEquipStatusActive => 'Active';

  @override
  String get mfgEquipStatusInactive => 'Inactive';

  @override
  String get mfgEquipAttachmentsTitle => 'Files (optional)';

  @override
  String get mfgEquipAttachImage => 'Equipment image';

  @override
  String get mfgEquipAttachManualOp => 'Operator manual (PDF)';

  @override
  String get mfgEquipAttachManualMaint => 'Maintenance manual (PDF)';

  @override
  String get mfgEquipAttachDatasheet => 'Datasheet (PDF)';

  @override
  String get mfgEquipAttachIntroVideo => 'Intro video (MP4)';

  @override
  String get mfgEquipPickFile => 'Choose';

  @override
  String get mfgEquipClearFile => 'Clear';

  @override
  String get mfgEquipSearchHint => 'Search name, model, or serial';

  @override
  String get mfgEquipFilterStatusLabel => 'List status';

  @override
  String get mfgEquipStatusFilterAll => 'All';

  @override
  String mfgEquipTemplatesCount(Object count) {
    return '$count official template(s)';
  }

  @override
  String get mfgEquipSortLabel => 'Sort list';

  @override
  String get mfgEquipSortName => 'Name (A–Z)';

  @override
  String get mfgEquipSortUpdated => 'Recently updated';

  @override
  String get mfgEquipSortTemplates => 'Most official templates';

  @override
  String mfgEquipListResultCount(Object count) {
    return '$count model(s) listed (up to 200).';
  }

  @override
  String get mfgEquipClearFilters => 'Clear filters';

  @override
  String get mfgEquipSnackPartialUpload =>
      'Equipment saved; some attachments failed.';

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
      'Your request is in the Fluxxo review queue. Estimated turnaround: 24–48 business hours. You will receive an email when approved.';

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
      '• Purpose: identification in trainings, certificates, and aggregated institution reports.\n• Sharing: individual data only with the instructor during the session; to the institution, in aggregated form.\n• Retention: up to 5 years after the last training for audit, unless you request deletion or anonymization.\n• Rights: access, correction, portability, and deletion via the Privacy menu (icon at the top).';

  @override
  String get trnLgpdCheckboxTitle =>
      'I have read and agree to the processing of my personal data under the App²cation Privacy Policy.';

  @override
  String get trnLgpdAfterConsentHint =>
      'After continuing, you can export or request account deletion anytime from the Privacy menu (shield icon) in the header.';

  @override
  String get trnBtnContinue => 'Continue';

  @override
  String get trnPreregTitle => 'Pre-registration';

  @override
  String get trnPreregSubtitle => 'Real data saved to your account.';

  @override
  String get trnFieldInstitutionOptional => 'Institution (optional)';

  @override
  String get trnInstitutionNone => 'No institution';

  @override
  String get trnProfileInstitutionHint =>
      'Linking a hospital unlocks the institution’s equipment park for training requests and may be required by your unit’s policy.';

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
  String get trnJoinIntroDetail =>
      'The instructor shares the code or hash after you are invited (email, app or in person). You can paste from a message; spaces are trimmed and letter case does not matter.';

  @override
  String get trnJoinAccessCodeHint => 'Paste the code from the instructor';

  @override
  String get trnJoinHashKeepTyping =>
      'Most codes are 12 characters — keep typing or paste the full code.';

  @override
  String get trnJoinHashFormatOk => 'Format looks valid. Tap confirm to join.';

  @override
  String get trnFieldAccessCode => 'Access code';

  @override
  String get trnBtnConfirmJoin => 'Confirm entry';

  @override
  String get trnJoinOfflineHint =>
      'The app cannot reach the server. Check your connection before confirming entry.';

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
  String get trnWaitingOfflineHint =>
      'We cannot reach the API. When you are back online, pull down or tap Refresh status to sync as soon as the instructor starts.';

  @override
  String get trnWaitingStatusChip => 'Status: waiting room active';

  @override
  String get trnWaitingTestConnection => 'Test connection and devices';

  @override
  String get trnWaitingCheckNow => 'Refresh status';

  @override
  String get trnWaitingPingOk => 'Server connection OK.';

  @override
  String get trnWaitingPingFail => 'Could not reach the server.';

  @override
  String get trnWaitingPrivacyNote =>
      'Camera and microphone stay off by default in this version.';

  @override
  String get trnHeaderProfileStep => 'Profile & institution';

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
  String get trnBtnContinueAfterFeedback => 'Continue';

  @override
  String get trnAnswerFeedbackCorrect => 'Correct.';

  @override
  String get trnAnswerFeedbackIncorrect => 'Incorrect.';

  @override
  String trnAnswerCorrectWas(Object label) {
    return 'Correct answer: $label';
  }

  @override
  String get trnBtnSubmitResponses => 'Submit responses';

  @override
  String get trnOptionalHint => 'Optional';

  @override
  String get trnResultTitle => 'Training completed';

  @override
  String get trnScoreLabel => 'Score (0–10)';

  @override
  String get trnResultApprovedBanner => 'Passed — score is 7.0 or higher.';

  @override
  String get trnResultInsufficientBanner =>
      'Score below 7.0. If unsure, speak with your instructor.';

  @override
  String get trnResultRecoveryNote =>
      'You are in recovery: complete the questions indicated by the instructor.';

  @override
  String trnResultInstitution(Object name) {
    return 'Institution: $name';
  }

  @override
  String get trnResultRefresh => 'Refresh status';

  @override
  String get trnResultCertificateHint =>
      'If the instructor just finished the training, refresh — your certificate can take a few seconds to appear.';

  @override
  String get trnResultCertificateDownload => 'Certificate (PDF)';

  @override
  String get trnResultFollowUpIntro =>
      'When the due window opens, tap Respond to complete the short questionnaire.';

  @override
  String get trnResultOfflineHint =>
      'Cannot reach the server. You can refresh when back online; the certificate (PDF) and follow-up questionnaire only work while online.';

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
  String get mfgTplErrQuestionNeedTwoOptions =>
      'Each question with a prompt needs at least two non-empty options.';

  @override
  String get mfgTplErrCorrectMustHaveLabel =>
      'The correct choice must have text (no empty correct option).';

  @override
  String get mfgTplBtnAddOption => 'Option';

  @override
  String get mfgTplRemoveOptionTooltip => 'Remove option';

  @override
  String get mfgTplMaxOptionsSnack => 'At most 12 options per question.';

  @override
  String get mfgTplOptionsCountHint =>
      '2–12 options; empty rows are ignored when saving.';

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
  String get mfgTplReloadTooltip => 'Reload from server';

  @override
  String get mfgTplRefreshHint =>
      'Pull down to reload from the server. Unsaved edits in the form are replaced.';

  @override
  String get mfgTplMoveUpTooltip => 'Move question up';

  @override
  String get mfgTplMoveDownTooltip => 'Move question down';

  @override
  String get mfgTplDiscardTitle => 'Discard changes?';

  @override
  String get mfgTplDiscardBody =>
      'You have unsaved edits. Leave without saving?';

  @override
  String get mfgTplKeepEditing => 'Keep editing';

  @override
  String get mfgTplDiscardLeave => 'Leave without saving';

  @override
  String get mfgTplSectionBlocks => 'Questionnaire sections';

  @override
  String get mfgTplFieldBlockTitle => 'Section title';

  @override
  String get mfgTplBtnAddBlock => 'Add section';

  @override
  String get mfgTplRemoveBlockTooltip =>
      'Remove section and merge questions into the section above';

  @override
  String mfgTplBlockDefaultTitle(int n) {
    return 'Section $n';
  }

  @override
  String get mfgTplViewEdit => 'Edit';

  @override
  String get mfgTplViewPreview => 'Preview';

  @override
  String get mfgTplPreviewBanner =>
      'Trainee-style preview: no answers are stored and the correct option is not highlighted.';

  @override
  String get mfgTplPreviewEmpty =>
      'No questions with a prompt to show. Switch to Edit and fill in at least one prompt.';

  @override
  String get mfgTplMoveBlockUpTooltip => 'Move section up';

  @override
  String get mfgTplMoveBlockDownTooltip => 'Move section down';

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

  @override
  String get loginIamManufacturer => 'I am a manufacturer';

  @override
  String get loginIamInstitution => 'I am an institution';

  @override
  String get loginIamInstructorLink => 'I am an instructor (Application)';

  @override
  String get loginInstitutionFootnote =>
      'Managers sign in with credentials issued by the institution or manufacturer. To join as clinical staff, use “Get started” as an instructor and request a hospital link.';

  @override
  String get mfgOnboardTitle => 'Manufacturer registration';

  @override
  String mfgOnboardStepCounter(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get mfgOnboardCorporateSection => 'Corporate details';

  @override
  String get mfgFieldLegalName => 'Legal name';

  @override
  String get mfgFieldTradeName => 'Trade name';

  @override
  String get mfgFieldStateRegistration => 'State registration (IE)';

  @override
  String get mfgFieldWebsite => 'Website';

  @override
  String get mfgFieldCommercialPhone => 'Commercial phone';

  @override
  String get mfgAddressSection => 'Address';

  @override
  String get mfgFieldCep => 'Postal code (CEP)';

  @override
  String get mfgCepLookup => 'Look up CEP';

  @override
  String get mfgFieldStreet => 'Street';

  @override
  String get mfgFieldNeighborhood => 'District';

  @override
  String get mfgFieldCity => 'City';

  @override
  String get mfgFieldState => 'State (UF)';

  @override
  String get mfgOnboardLegalRepSection => 'Legal representative';

  @override
  String get mfgFieldLegalRepName => 'Full name';

  @override
  String get mfgFieldLegalRepCpf => 'CPF';

  @override
  String get mfgFieldLegalRepRole => 'Role';

  @override
  String get mfgFieldLegalRepPhone => 'Direct phone';

  @override
  String get mfgOnboardDocsSection => 'Documents for validation';

  @override
  String get mfgDocFormatsHint => 'Accepted: PDF, JPG, PNG (max 10 MB each).';

  @override
  String get mfgDocCnpjProof => 'CNPJ registration proof';

  @override
  String get mfgDocArticles => 'Articles of incorporation (or equivalent)';

  @override
  String get mfgDocAddressProof =>
      'Proof of address (utility bill, up to 3 months)';

  @override
  String get mfgDeclarationLabel =>
      'I declare that all information is truthful and understand that false statements may incur legal liability.';

  @override
  String get mfgSendForReview => 'Submit for review';

  @override
  String get mfgPendingTitle => 'Registration under review';

  @override
  String get mfgPendingBody =>
      'Your documents were submitted successfully and are being reviewed by our team.';

  @override
  String get mfgPendingSla => 'Estimated time: 24–48 business hours.';

  @override
  String get mfgPendingEmailNotice =>
      'You will receive an email once your registration is approved.';

  @override
  String get mfgPendingProtocol => 'Protocol number';

  @override
  String get mfgPendingStatusReview => 'Status: under review';

  @override
  String get mfgPendingSubmittedAt => 'Submitted at';

  @override
  String get mfgPendingSupport => 'Help: suporte@app2cation.com';

  @override
  String get mfgCepInvalid => 'Enter an 8-digit CEP.';

  @override
  String get mfgCepNotFound => 'CEP not found.';

  @override
  String get mfgPickDoc => 'Attach file';

  @override
  String get mfgRemoveDoc => 'Remove';

  @override
  String get mfgLogout => 'Sign out';

  @override
  String get mfgOnboardFieldsRequired =>
      'Fill all required fields (CNPJ 14 digits, CEP 8 digits, state code 2 letters).';

  @override
  String get mfgAcceptDeclaration =>
      'Accept the declaration before submitting for review.';

  @override
  String mfgDocMissingKind(Object title) {
    return 'Missing document: $title';
  }

  @override
  String get inviteAcceptTitle => 'Accept invitation';

  @override
  String get inviteMissingToken => 'Invalid or incomplete invitation link.';

  @override
  String inviteStatusNotPending(Object status) {
    return 'This invitation is no longer available (status: $status).';
  }

  @override
  String get inviteRoleLabel => 'Role';

  @override
  String get inviteEmailLabel => 'Email';

  @override
  String get inviteInstitutionLabel => 'Institution';

  @override
  String get inviteNameLabel => 'Full name';

  @override
  String get invitePasswordLabel => 'Password';

  @override
  String get invitePasswordConfirmLabel => 'Confirm password';

  @override
  String get inviteActivate => 'Activate account';

  @override
  String get invitePasswordMismatch => 'Passwords do not match.';

  @override
  String get inviteNameRequired => 'Please enter your name.';

  @override
  String get inviteCpfRequired => 'Enter your CPF to complete the invitation.';

  @override
  String get inviteCpfLabel => 'CPF (digits only)';

  @override
  String get traineeJoinTitle => 'Join training';

  @override
  String get traineeJoinSubtitle =>
      'Create your trainee account to access the training from this link.';

  @override
  String get traineeJoinName => 'Full name';

  @override
  String get traineeJoinEmail => 'Email';

  @override
  String get traineeJoinPassword => 'Password';

  @override
  String get traineeJoinPasswordConfirm => 'Confirm password';

  @override
  String get traineeJoinSubmit => 'Register and join';

  @override
  String get traineeJoinMissingHash => 'Training code missing from the link.';

  @override
  String get mfgProvisioningHubTitle => 'Institutions and invitations';

  @override
  String get mfgProvisioningHubSubtitle =>
      'Create institutions and invite managers and instructors.';

  @override
  String get mfgProvisioningNavTitle => 'Provisioning';

  @override
  String get mfgProvisioningCreateInstitutionTitle => 'New institution';

  @override
  String get mfgProvisioningInstitutionListTitle => 'Your institutions';

  @override
  String get mfgProvisioningInviteCreateTitle => 'New invitation';

  @override
  String get mfgProvisioningInvitationListTitle => 'Recent invitations';

  @override
  String get mfgProvisioningFieldName => 'Name';

  @override
  String get mfgProvisioningFieldCnpj => 'CNPJ';

  @override
  String get mfgProvisioningFieldInviteEmail => 'Invitee email';

  @override
  String get mfgProvisioningFieldInviteNameOptional =>
      'Invitee name (optional)';

  @override
  String get mfgProvisioningFieldInviteCpfOptional => 'Invitee CPF (optional)';

  @override
  String get mfgProvisioningRoleGestor => 'Institution manager';

  @override
  String get mfgProvisioningRoleInstructor => 'Instructor';

  @override
  String get mfgProvisioningInviteRoleLabel => 'Invitation role';

  @override
  String get mfgProvisioningSubmitCreateInstitution => 'Create institution';

  @override
  String get mfgProvisioningSubmitCreateInvite => 'Send invitation';

  @override
  String get mfgProvisioningRevokeInvite => 'Revoke';

  @override
  String get mfgProvisioningEmptyInstitutions =>
      'No institutions created by this manufacturer yet.';

  @override
  String get mfgProvisioningPickInstitution =>
      'Create an institution first to send invitations.';

  @override
  String get mfgProvisioningInstitutionDropdownLabel =>
      'Institution for invitation';

  @override
  String get mfgProvisioningNeedInstitutionFirst => 'Select an institution.';

  @override
  String get mfgProvisioningSuccessInstitution => 'Institution created.';

  @override
  String get mfgProvisioningSuccessInvite => 'Invitation sent.';
}
