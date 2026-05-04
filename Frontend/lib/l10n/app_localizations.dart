import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Appcation'**
  String get appTitle;

  /// No description provided for @loginShellTitle.
  ///
  /// In pt, this message translates to:
  /// **'Login Universal'**
  String get loginShellTitle;

  /// No description provided for @loginBrandTitle.
  ///
  /// In pt, this message translates to:
  /// **'App²cation'**
  String get loginBrandTitle;

  /// No description provided for @loginTagline.
  ///
  /// In pt, this message translates to:
  /// **'Treino clínico com ritmo e clareza'**
  String get loginTagline;

  /// No description provided for @loginAccessHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesse o App²cation'**
  String get loginAccessHeroTitle;

  /// No description provided for @loginAccessHeroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Plataforma de gestão de treinamentos para equipamentos hospitalares'**
  String get loginAccessHeroSubtitle;

  /// No description provided for @loginCardSignInHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Entre na sua conta'**
  String get loginCardSignInHeadline;

  /// No description provided for @loginCardSignInLead.
  ///
  /// In pt, this message translates to:
  /// **'Use o Google ou o e-mail e senha da sua instituição.'**
  String get loginCardSignInLead;

  /// No description provided for @loginUrsSecurePortalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesso seguro ao portal'**
  String get loginUrsSecurePortalSubtitle;

  /// No description provided for @loginSectionLoginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Login'**
  String get loginSectionLoginTitle;

  /// No description provided for @loginInstitutionalCredentialsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Credenciais (e-mail)'**
  String get loginInstitutionalCredentialsTitle;

  /// No description provided for @loginFieldIdentifier.
  ///
  /// In pt, this message translates to:
  /// **'Identificador'**
  String get loginFieldIdentifier;

  /// No description provided for @loginFieldIdentifierHint.
  ///
  /// In pt, this message translates to:
  /// **'CPF, CRM, CNPJ ou e-mail da instituição'**
  String get loginFieldIdentifierHint;

  /// No description provided for @loginIdentityPatient.
  ///
  /// In pt, this message translates to:
  /// **'Perfil: treinando (CPF válido)'**
  String get loginIdentityPatient;

  /// No description provided for @loginIdentityInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Perfil: instituição / fabricante (CNPJ)'**
  String get loginIdentityInstitution;

  /// No description provided for @loginIdentityDoctor.
  ///
  /// In pt, this message translates to:
  /// **'Perfil: instrutor (CRM)'**
  String get loginIdentityDoctor;

  /// No description provided for @loginIdentitySystem.
  ///
  /// In pt, this message translates to:
  /// **'Conta interna (login alfanumérico)'**
  String get loginIdentitySystem;

  /// No description provided for @loginIdentityEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail institucional'**
  String get loginIdentityEmail;

  /// No description provided for @loginIdentityUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Identificador não reconhecido — use e-mail válido ou Google'**
  String get loginIdentityUnknown;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccountPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta?'**
  String get loginNoAccountPrefix;

  /// No description provided for @loginNoAccountAction.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get loginNoAccountAction;

  /// No description provided for @loginUrsHeroTagline.
  ///
  /// In pt, this message translates to:
  /// **'Conectando cuidado e tecnologia em tempo real'**
  String get loginUrsHeroTagline;

  /// No description provided for @loginEmptyIdentifierPassword.
  ///
  /// In pt, this message translates to:
  /// **'Identificador ou senha em branco.'**
  String get loginEmptyIdentifierPassword;

  /// No description provided for @loginIdentifierInvalidClient.
  ///
  /// In pt, this message translates to:
  /// **'Identificador inválido. Use CPF, CRM, CNPJ válido, login administrativo ou e-mail.'**
  String get loginIdentifierInvalidClient;

  /// No description provided for @loginPasswordRequiresEmail.
  ///
  /// In pt, this message translates to:
  /// **'Para entrar com senha neste portal, use o e-mail da sua conta (ou Continuar com Google).'**
  String get loginPasswordRequiresEmail;

  /// No description provided for @loginShowPassword.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get loginHidePassword;

  /// No description provided for @loginNavQuestions.
  ///
  /// In pt, this message translates to:
  /// **'Dúvidas?'**
  String get loginNavQuestions;

  /// No description provided for @loginNavStartNow.
  ///
  /// In pt, this message translates to:
  /// **'Começar agora'**
  String get loginNavStartNow;

  /// No description provided for @loginNavHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho conta'**
  String get loginNavHaveAccount;

  /// No description provided for @loginFooterTerms.
  ///
  /// In pt, this message translates to:
  /// **'Termos de uso'**
  String get loginFooterTerms;

  /// No description provided for @loginFooterPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade'**
  String get loginFooterPrivacy;

  /// No description provided for @loginFooterCookies.
  ///
  /// In pt, this message translates to:
  /// **'Cookies'**
  String get loginFooterCookies;

  /// No description provided for @loginFooterHelp.
  ///
  /// In pt, this message translates to:
  /// **'Centro de ajuda'**
  String get loginFooterHelp;

  /// No description provided for @loginFooterSystemsOk.
  ///
  /// In pt, this message translates to:
  /// **'Todos os sistemas operacionais'**
  String get loginFooterSystemsOk;

  /// No description provided for @loginFooterSupportPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Não consegue aceder?'**
  String get loginFooterSupportPrefix;

  /// No description provided for @loginFooterSupportLink.
  ///
  /// In pt, this message translates to:
  /// **'Fale com o suporte técnico'**
  String get loginFooterSupportLink;

  /// No description provided for @loginFooterSoon.
  ///
  /// In pt, this message translates to:
  /// **'Disponível em breve.'**
  String get loginFooterSoon;

  /// No description provided for @authTrackCpfLabel.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get authTrackCpfLabel;

  /// No description provided for @authTrackCnpjLabel.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ'**
  String get authTrackCnpjLabel;

  /// No description provided for @authTrackSegmentSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pessoa física (treinando ou instrutor) ou empresa (fabricante). Gestor de instituição só por convite no painel.'**
  String get authTrackSegmentSubtitle;

  /// No description provided for @loginGoogleProfileSection.
  ///
  /// In pt, this message translates to:
  /// **'Perfil (primeiro acesso Google)'**
  String get loginGoogleProfileSection;

  /// No description provided for @loginGoogleProfileSectionCpf.
  ///
  /// In pt, this message translates to:
  /// **'Google — pessoa física (treinando ou instrutor)'**
  String get loginGoogleProfileSectionCpf;

  /// No description provided for @loginGoogleProfileSectionCnpj.
  ///
  /// In pt, this message translates to:
  /// **'Google — fabricante (empresa / CNPJ)'**
  String get loginGoogleProfileSectionCnpj;

  /// No description provided for @googleRoleTrainee.
  ///
  /// In pt, this message translates to:
  /// **'Treinando'**
  String get googleRoleTrainee;

  /// No description provided for @googleRoleInstructor.
  ///
  /// In pt, this message translates to:
  /// **'Instrutor'**
  String get googleRoleInstructor;

  /// No description provided for @googleRoleInstitutionAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Gestor'**
  String get googleRoleInstitutionAdmin;

  /// No description provided for @googleRoleManufacturerAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Fabricante'**
  String get googleRoleManufacturerAdmin;

  /// No description provided for @mfgCompanyLabel.
  ///
  /// In pt, this message translates to:
  /// **'Empresa (fabricante)'**
  String get mfgCompanyLabel;

  /// No description provided for @mfgCnpjOptionalLabel.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ (opcional)'**
  String get mfgCnpjOptionalLabel;

  /// No description provided for @institutionLoadingGoogle.
  ///
  /// In pt, this message translates to:
  /// **'A carregar instituições… Se a lista estiver vazia, registe primeiro uma instituição (conta instrutor) ou use e-mail e senha.'**
  String get institutionLoadingGoogle;

  /// No description provided for @institutionPickerLabelGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Instituição (gestor)'**
  String get institutionPickerLabelGoogle;

  /// No description provided for @googleConnecting.
  ///
  /// In pt, this message translates to:
  /// **'A ligar ao Google…'**
  String get googleConnecting;

  /// No description provided for @googleContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get googleContinue;

  /// No description provided for @loginOrEmail.
  ///
  /// In pt, this message translates to:
  /// **'ou e-mail'**
  String get loginOrEmail;

  /// No description provided for @fieldEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get fieldPassword;

  /// No description provided for @valEmailRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o e-mail.'**
  String get valEmailRequired;

  /// No description provided for @valEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido.'**
  String get valEmailInvalid;

  /// No description provided for @valPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a senha.'**
  String get valPasswordRequired;

  /// No description provided for @actionSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get actionSignIn;

  /// No description provided for @loginOrgHint.
  ///
  /// In pt, this message translates to:
  /// **'Gestor de hospital ou clínica: use o e-mail e senha que a instituição criou para si no painel interno.'**
  String get loginOrgHint;

  /// No description provided for @actionCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get actionCreateAccount;

  /// No description provided for @actionBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get actionBack;

  /// No description provided for @registerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha CPF ou CNPJ, o perfil e preencha os dados.'**
  String get registerSubtitle;

  /// No description provided for @registerAccountTypeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de conta'**
  String get registerAccountTypeTitle;

  /// No description provided for @registerAccountTypeTitleCpf.
  ///
  /// In pt, this message translates to:
  /// **'Perfil (CPF)'**
  String get registerAccountTypeTitleCpf;

  /// No description provided for @registerAccountTypeTitleCnpj.
  ///
  /// In pt, this message translates to:
  /// **'Conta fabricante (CNPJ)'**
  String get registerAccountTypeTitleCnpj;

  /// No description provided for @registerManagerInviteHint.
  ///
  /// In pt, this message translates to:
  /// **'Gestor de instituição não se cadastra aqui: o hospital ou fabricante cria o acesso no painel.'**
  String get registerManagerInviteHint;

  /// No description provided for @registerInstitutionsLoading.
  ///
  /// In pt, this message translates to:
  /// **'A carregar instituições… Se a lista estiver vazia, ainda não há hospitais registados na API.'**
  String get registerInstitutionsLoading;

  /// No description provided for @fieldInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Instituição'**
  String get fieldInstitution;

  /// No description provided for @fieldFullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get fieldFullName;

  /// No description provided for @valNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome.'**
  String get valNameRequired;

  /// No description provided for @fieldPasswordRegister.
  ///
  /// In pt, this message translates to:
  /// **'Senha (mín. 8 caracteres)'**
  String get fieldPasswordRegister;

  /// No description provided for @valPasswordMin8.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 8 caracteres.'**
  String get valPasswordMin8;

  /// No description provided for @fieldCompanyName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da empresa'**
  String get fieldCompanyName;

  /// No description provided for @registerMfgCompanyOptionalDomain.
  ///
  /// In pt, this message translates to:
  /// **'Obrigatório só no primeiro registo deste domínio; deixe em branco para juntar-se a um fabricante já criado.'**
  String get registerMfgCompanyOptionalDomain;

  /// No description provided for @valCompanyNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome da empresa.'**
  String get valCompanyNameRequired;

  /// No description provided for @actionCompleteRegistration.
  ///
  /// In pt, this message translates to:
  /// **'Concluir cadastro'**
  String get actionCompleteRegistration;

  /// No description provided for @errApiConnection.
  ///
  /// In pt, this message translates to:
  /// **'Falha de conexão com a API.'**
  String get errApiConnection;

  /// No description provided for @errMfgNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome da empresa.'**
  String get errMfgNameRequired;

  /// No description provided for @errSelectInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a instituição na lista.'**
  String get errSelectInstitution;

  /// No description provided for @errGoogleClientId.
  ///
  /// In pt, this message translates to:
  /// **'Configure GOOGLE_WEB_CLIENT_ID ao executar o Flutter (mesmo ID que GOOGLE_CLIENT_ID no servidor).'**
  String get errGoogleClientId;

  /// No description provided for @errMfgNameBeforeGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Informe o nome do fabricante antes de continuar com Google.'**
  String get errMfgNameBeforeGoogle;

  /// No description provided for @errSelectInstitutionGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a instituição na lista (ou aguarde o carregamento).'**
  String get errSelectInstitutionGoogle;

  /// No description provided for @shellTitleOverview.
  ///
  /// In pt, this message translates to:
  /// **'Visão Geral'**
  String get shellTitleOverview;

  /// No description provided for @shellTitleCommandRoom.
  ///
  /// In pt, this message translates to:
  /// **'Sala de Comando'**
  String get shellTitleCommandRoom;

  /// No description provided for @shellTitleNewTraining.
  ///
  /// In pt, this message translates to:
  /// **'Novo Treinamento'**
  String get shellTitleNewTraining;

  /// No description provided for @shellTitleCredentialing.
  ///
  /// In pt, this message translates to:
  /// **'Credenciamento'**
  String get shellTitleCredentialing;

  /// No description provided for @shellTitleTrainingRequests.
  ///
  /// In pt, this message translates to:
  /// **'Pedidos de treino'**
  String get shellTitleTrainingRequests;

  /// No description provided for @shellTitleTechPark.
  ///
  /// In pt, this message translates to:
  /// **'Parque tecnológico'**
  String get shellTitleTechPark;

  /// No description provided for @shellTitleEndorsements.
  ///
  /// In pt, this message translates to:
  /// **'Endossos ao fabricante'**
  String get shellTitleEndorsements;

  /// No description provided for @shellTitleFluxxoReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisão de fabricantes'**
  String get shellTitleFluxxoReview;

  /// No description provided for @shellNavDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get shellNavDashboard;

  /// No description provided for @shellNavCommandRoom.
  ///
  /// In pt, this message translates to:
  /// **'Sala de Comando'**
  String get shellNavCommandRoom;

  /// No description provided for @shellNavTrainings.
  ///
  /// In pt, this message translates to:
  /// **'Treinamentos'**
  String get shellNavTrainings;

  /// No description provided for @shellNavTrainingRequests.
  ///
  /// In pt, this message translates to:
  /// **'Pedidos de treino'**
  String get shellNavTrainingRequests;

  /// No description provided for @shellNavTechPark.
  ///
  /// In pt, this message translates to:
  /// **'Parque tecnológico'**
  String get shellNavTechPark;

  /// No description provided for @shellNavEndorsementsShort.
  ///
  /// In pt, this message translates to:
  /// **'Endossos fabricante'**
  String get shellNavEndorsementsShort;

  /// No description provided for @shellNavFluxxoReview.
  ///
  /// In pt, this message translates to:
  /// **'Fabricantes'**
  String get shellNavFluxxoReview;

  /// No description provided for @shellNavCredentialing.
  ///
  /// In pt, this message translates to:
  /// **'Credenciamento'**
  String get shellNavCredentialing;

  /// No description provided for @shellNavPostTrainingResults.
  ///
  /// In pt, this message translates to:
  /// **'Resultados do treino'**
  String get shellNavPostTrainingResults;

  /// No description provided for @shellTitlePostTrainingResults.
  ///
  /// In pt, this message translates to:
  /// **'Resultados e repescagem'**
  String get shellTitlePostTrainingResults;

  /// No description provided for @postTrainingIntro.
  ///
  /// In pt, this message translates to:
  /// **'Revise participantes após a sessão, aplique repescagem a quem precisar e finalize quando todos estiverem avaliados. O controlo em tempo real permanece na Sala de comando.'**
  String get postTrainingIntro;

  /// No description provided for @postTrainingPickTraining.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um treino para carregar a lista de inscritos.'**
  String get postTrainingPickTraining;

  /// No description provided for @postTrainingOutcomeApproved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado (≥ 7,0)'**
  String get postTrainingOutcomeApproved;

  /// No description provided for @postTrainingOutcomeInsufficient.
  ///
  /// In pt, this message translates to:
  /// **'Insuficiente (< 7,0)'**
  String get postTrainingOutcomeInsufficient;

  /// No description provided for @postTrainingOutcomeRecovery.
  ///
  /// In pt, this message translates to:
  /// **'Em recuperação'**
  String get postTrainingOutcomeRecovery;

  /// No description provided for @postTrainingOutcomeInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em curso'**
  String get postTrainingOutcomeInProgress;

  /// No description provided for @postTrainingOutcomeWaitingRoom.
  ///
  /// In pt, this message translates to:
  /// **'Sala de espera'**
  String get postTrainingOutcomeWaitingRoom;

  /// No description provided for @postTrainingOutcomeCompletedNoGrade.
  ///
  /// In pt, this message translates to:
  /// **'Concluído (sem nota)'**
  String get postTrainingOutcomeCompletedNoGrade;

  /// No description provided for @postTrainingFinishTraining.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar treino'**
  String get postTrainingFinishTraining;

  /// No description provided for @postTrainingFinishTrainingConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar este treino?'**
  String get postTrainingFinishTrainingConfirmTitle;

  /// No description provided for @postTrainingFinishTrainingConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'O estado passa a concluído. Os treinandos deixam de responder ao questionário nesta sessão.'**
  String get postTrainingFinishTrainingConfirmBody;

  /// No description provided for @postTrainingFinishTrainingDone.
  ///
  /// In pt, this message translates to:
  /// **'Treino concluído. Certificados garantidos para quem tem nota ≥ limiar.'**
  String get postTrainingFinishTrainingDone;

  /// No description provided for @postTrainingCertificatePdfTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Descarregar certificado (PDF)'**
  String get postTrainingCertificatePdfTooltip;

  /// No description provided for @postTrainingIssueCertificate.
  ///
  /// In pt, this message translates to:
  /// **'Emitir certificado'**
  String get postTrainingIssueCertificate;

  /// No description provided for @postTrainingIssueCertificateTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Registar o certificado na base quando a nota já é ≥ ao limiar (ex.: correção após encerramento).'**
  String get postTrainingIssueCertificateTooltip;

  /// No description provided for @postTrainingIssueCertificateDone.
  ///
  /// In pt, this message translates to:
  /// **'Certificado emitido.'**
  String get postTrainingIssueCertificateDone;

  /// No description provided for @postTrainingIssueCertificateAlready.
  ///
  /// In pt, this message translates to:
  /// **'Este participante já tinha certificado.'**
  String get postTrainingIssueCertificateAlready;

  /// No description provided for @postTrainingExportCertificatesCsvTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Descarregar CSV com inscritos e certificados deste treino (auditoria).'**
  String get postTrainingExportCertificatesCsvTooltip;

  /// No description provided for @postTrainingExportCertificatesDone.
  ///
  /// In pt, this message translates to:
  /// **'Relatório CSV descarregado.'**
  String get postTrainingExportCertificatesDone;

  /// No description provided for @postTrainingExportCertificatesCsvFilename.
  ///
  /// In pt, this message translates to:
  /// **'appcation-treino-{trainingId}-{stamp}.csv'**
  String postTrainingExportCertificatesCsvFilename(
    int trainingId,
    String stamp,
  );

  /// No description provided for @postTrainingExportCertificatesPdfTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Descarregar PDF com inscritos e certificados deste treino (auditoria).'**
  String get postTrainingExportCertificatesPdfTooltip;

  /// No description provided for @postTrainingExportCertificatesPdfDone.
  ///
  /// In pt, this message translates to:
  /// **'Relatório PDF descarregado.'**
  String get postTrainingExportCertificatesPdfDone;

  /// No description provided for @postTrainingExportCertificatesPdfFilename.
  ///
  /// In pt, this message translates to:
  /// **'appcation-treino-{trainingId}-{stamp}.pdf'**
  String postTrainingExportCertificatesPdfFilename(
    int trainingId,
    String stamp,
  );

  /// No description provided for @shellLinkInstitutionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vincule a sua instituição'**
  String get shellLinkInstitutionTitle;

  /// No description provided for @shellLinkInstitutionBody.
  ///
  /// In pt, this message translates to:
  /// **'Sem isto não vê pedidos de treino nem o dashboard agregado.'**
  String get shellLinkInstitutionBody;

  /// No description provided for @shellLinkInstitutionEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Não há instituições na API — crie uma em Credenciamento (como instrutor) ou peça ao administrador.'**
  String get shellLinkInstitutionEmpty;

  /// No description provided for @shellSaveLink.
  ///
  /// In pt, this message translates to:
  /// **'Guardar vínculo'**
  String get shellSaveLink;

  /// No description provided for @shellPickInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a instituição.'**
  String get shellPickInstitution;

  /// No description provided for @shellAreaManager.
  ///
  /// In pt, this message translates to:
  /// **'Área do gestor'**
  String get shellAreaManager;

  /// No description provided for @shellAreaInstructor.
  ///
  /// In pt, this message translates to:
  /// **'Área do instrutor'**
  String get shellAreaInstructor;

  /// No description provided for @shellDefaultUserName.
  ///
  /// In pt, this message translates to:
  /// **'Instrutor'**
  String get shellDefaultUserName;

  /// No description provided for @actionSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get actionSignOut;

  /// No description provided for @profileGateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil não reconhecido'**
  String get profileGateTitle;

  /// No description provided for @profileGateBody.
  ///
  /// In pt, this message translates to:
  /// **'A sessão está ativa, mas este utilizador não tem um perfil associado a uma área da aplicação (treinando, instrutor, gestor ou fabricante). Termine a sessão e entre novamente; no primeiro acesso com Google, escolha o tipo de conta correto.'**
  String get profileGateBody;

  /// No description provided for @profileGateDocHint.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo oficial do produto: docs/product/fluxo_app2cation.mermaid'**
  String get profileGateDocHint;

  /// No description provided for @profileGateYourAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta com sessão iniciada'**
  String get profileGateYourAccount;

  /// No description provided for @profileGateRoleFromApi.
  ///
  /// In pt, this message translates to:
  /// **'Função (role) no servidor: {role}'**
  String profileGateRoleFromApi(Object role);

  /// No description provided for @profileGateClaimSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Definir perfil (uma vez)'**
  String get profileGateClaimSectionTitle;

  /// No description provided for @profileGateClaimIntro.
  ///
  /// In pt, this message translates to:
  /// **'Se a sua conta deve ser treinando, instrutor ou administrador de fabricante mas a função no servidor estava em falta ou inválida, escolha abaixo. Só é permitido até existir uma função válida gravada.'**
  String get profileGateClaimIntro;

  /// No description provided for @profileGateClaimHint.
  ///
  /// In pt, this message translates to:
  /// **'Gestor de instituição não se define aqui — o hospital ou o fabricante cria esse acesso.'**
  String get profileGateClaimHint;

  /// No description provided for @profileGateChooseRole.
  ///
  /// In pt, this message translates to:
  /// **'Perfil na plataforma'**
  String get profileGateChooseRole;

  /// No description provided for @profileGateConfirmProfile.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar perfil'**
  String get profileGateConfirmProfile;

  /// No description provided for @profileGatePickRoleFirst.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um perfil primeiro.'**
  String get profileGatePickRoleFirst;

  /// No description provided for @profileGateRetryLaterOrSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível sincronizar agora. Tente de novo dentro de momentos ou saia e entre novamente.'**
  String get profileGateRetryLaterOrSignOut;

  /// No description provided for @loginGoogleTriageHint.
  ///
  /// In pt, this message translates to:
  /// **'Depois de entrar com o Google, escolhe o teu perfil em dois passos (tipo de conta e, se necessário, dados da empresa).'**
  String get loginGoogleTriageHint;

  /// No description provided for @profileTriageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolhe o teu perfil'**
  String get profileTriageTitle;

  /// No description provided for @profileTriageSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecciona o tipo de conta. No passo seguinte confirmas ou completas os dados para vincular a conta Google.'**
  String get profileTriageSubtitle;

  /// No description provided for @profileTriageStep2Title.
  ///
  /// In pt, this message translates to:
  /// **'Dados do perfil'**
  String get profileTriageStep2Title;

  /// No description provided for @profileTriageTraineeBody.
  ///
  /// In pt, this message translates to:
  /// **'Como treinando participas em sessões com código, respondes ao questionário e acedes a certificados.'**
  String get profileTriageTraineeBody;

  /// No description provided for @profileTriageInstructorBody.
  ///
  /// In pt, this message translates to:
  /// **'Como instrutor crias e conduzes treinos e credencias-te em instituições e fabricantes quando aplicável.'**
  String get profileTriageInstructorBody;

  /// No description provided for @profileTriageManufacturerBody.
  ///
  /// In pt, this message translates to:
  /// **'Indica o nome público da empresa e, opcionalmente, o CNPJ. O domínio do teu e-mail determina a área de fabricante.'**
  String get profileTriageManufacturerBody;

  /// No description provided for @profileTriageBack.
  ///
  /// In pt, this message translates to:
  /// **'Alterar tipo de perfil'**
  String get profileTriageBack;

  /// No description provided for @actionRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get actionRetry;

  /// No description provided for @dashLinkInstitutionForKpis.
  ///
  /// In pt, this message translates to:
  /// **'Associe a sua instituição no aviso laranja no topo para ver indicadores agregados.'**
  String get dashLinkInstitutionForKpis;

  /// No description provided for @dashKpiTrainings.
  ///
  /// In pt, this message translates to:
  /// **'Treinamentos'**
  String get dashKpiTrainings;

  /// No description provided for @dashKpiFinished.
  ///
  /// In pt, this message translates to:
  /// **'Encerrados'**
  String get dashKpiFinished;

  /// No description provided for @dashKpiUniqueParticipants.
  ///
  /// In pt, this message translates to:
  /// **'Participantes únicos'**
  String get dashKpiUniqueParticipants;

  /// No description provided for @dashKpiAvgCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Média (concluídos)'**
  String get dashKpiAvgCompleted;

  /// No description provided for @dashKpiApprovalRate.
  ///
  /// In pt, this message translates to:
  /// **'Taxa aprovação'**
  String get dashKpiApprovalRate;

  /// No description provided for @dashSeasonRankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ranking por temporada'**
  String get dashSeasonRankingTitle;

  /// No description provided for @dashSeasonRankingHint.
  ///
  /// In pt, this message translates to:
  /// **'Treinos oficiais ligados a fabricantes contam para as temporadas definidas pelo fabricante.'**
  String get dashSeasonRankingHint;

  /// No description provided for @dashRecentTrainings.
  ///
  /// In pt, this message translates to:
  /// **'Treinamentos recentes'**
  String get dashRecentTrainings;

  /// No description provided for @dashNoTrainingsYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum treinamento ainda. Crie um em Treinamentos.'**
  String get dashNoTrainingsYet;

  /// No description provided for @dashSeasonPoints.
  ///
  /// In pt, this message translates to:
  /// **'{points} pts'**
  String dashSeasonPoints(Object points);

  /// No description provided for @dashInstitutionKpisTitle.
  ///
  /// In pt, this message translates to:
  /// **'Indicadores da instituição'**
  String get dashInstitutionKpisTitle;

  /// No description provided for @dashInstitutionLgpdNote.
  ///
  /// In pt, this message translates to:
  /// **'Dados agregados — sem identificação individual (LGPD).'**
  String get dashInstitutionLgpdNote;

  /// No description provided for @dashInstitutionAlertPendingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedidos por rever'**
  String get dashInstitutionAlertPendingTitle;

  /// No description provided for @dashInstitutionAlertPendingBody.
  ///
  /// In pt, this message translates to:
  /// **'Existem {count} pedido(s) pendente(s) na fila. Abra o quadro para rever e agendar.'**
  String dashInstitutionAlertPendingBody(int count);

  /// No description provided for @dashInstitutionShortcutsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Áreas do gestor'**
  String get dashInstitutionShortcutsTitle;

  /// No description provided for @dashExportCsv.
  ///
  /// In pt, this message translates to:
  /// **'Exportar CSV'**
  String get dashExportCsv;

  /// No description provided for @dashExportPdf.
  ///
  /// In pt, this message translates to:
  /// **'Exportar PDF'**
  String get dashExportPdf;

  /// No description provided for @dashKpiPendingRequests.
  ///
  /// In pt, this message translates to:
  /// **'Pedidos pendentes'**
  String get dashKpiPendingRequests;

  /// No description provided for @dashKpiInstitutionTrainings.
  ///
  /// In pt, this message translates to:
  /// **'Treinos (instituição)'**
  String get dashKpiInstitutionTrainings;

  /// No description provided for @dashKpiEnrollmentsTotal.
  ///
  /// In pt, this message translates to:
  /// **'Inscrições (total)'**
  String get dashKpiEnrollmentsTotal;

  /// No description provided for @dashKpiCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas'**
  String get dashKpiCompleted;

  /// No description provided for @dashKpiCompletionRate.
  ///
  /// In pt, this message translates to:
  /// **'Taxa conclusão'**
  String get dashKpiCompletionRate;

  /// No description provided for @dashKpiAvgScoreOverall.
  ///
  /// In pt, this message translates to:
  /// **'Média notas (geral)'**
  String get dashKpiAvgScoreOverall;

  /// No description provided for @dashByEquipment.
  ///
  /// In pt, this message translates to:
  /// **'Por equipamento'**
  String get dashByEquipment;

  /// No description provided for @dashNoEquipmentData.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados por equipamento ainda.'**
  String get dashNoEquipmentData;

  /// No description provided for @dashEquipmentSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Inscrições: {enr} · Concl.: {done} · Taxa: {rate}% · Média nota: {avg}'**
  String dashEquipmentSubtitle(
    Object enr,
    Object done,
    Object rate,
    Object avg,
  );

  /// No description provided for @dashSectorAveragesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Por setor (treinos da instituição)'**
  String get dashSectorAveragesTitle;

  /// No description provided for @dashNoSectorHistory.
  ///
  /// In pt, this message translates to:
  /// **'Sem histórico por setor.'**
  String get dashNoSectorHistory;

  /// No description provided for @dashSectorSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Inscrições: {total} · Concluídas: {done} · Com nota: {scored} · Média: {avg}'**
  String dashSectorSubtitle(int total, int done, int scored, String avg);

  /// No description provided for @trainingSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configuração'**
  String get trainingSectionTitle;

  /// No description provided for @trainingFieldTitle.
  ///
  /// In pt, this message translates to:
  /// **'Título do treinamento'**
  String get trainingFieldTitle;

  /// No description provided for @trainingTypeOfficial.
  ///
  /// In pt, this message translates to:
  /// **'Oficial'**
  String get trainingTypeOfficial;

  /// No description provided for @trainingTypeCustom.
  ///
  /// In pt, this message translates to:
  /// **'Personalizado'**
  String get trainingTypeCustom;

  /// No description provided for @trainingScheduledLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data/hora (opcional)'**
  String get trainingScheduledLabel;

  /// No description provided for @trainingScheduledHint.
  ///
  /// In pt, this message translates to:
  /// **'AAAA-MM-DD HH:MM'**
  String get trainingScheduledHint;

  /// No description provided for @trainingCreateButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar treinamento'**
  String get trainingCreateButton;

  /// No description provided for @trainingTemplateCardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Template oficial (fabricante)'**
  String get trainingTemplateCardTitle;

  /// No description provided for @trainingTemplateCardBody.
  ///
  /// In pt, this message translates to:
  /// **'Clona o questionário homologado. Requer homologação aprovada com o fabricante.'**
  String get trainingTemplateCardBody;

  /// No description provided for @trainingTemplateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Template'**
  String get trainingTemplateLabel;

  /// No description provided for @trainingUseTemplateButton.
  ///
  /// In pt, this message translates to:
  /// **'Usar template na instituição selecionada'**
  String get trainingUseTemplateButton;

  /// No description provided for @trainingJoinCodeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Código de entrada (repasse aos treinandos)'**
  String get trainingJoinCodeTitle;

  /// No description provided for @trainingInternalId.
  ///
  /// In pt, this message translates to:
  /// **'ID interno: {id}'**
  String trainingInternalId(Object id);

  /// No description provided for @trainingPostRepescageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nota após repescagem'**
  String get trainingPostRepescageTitle;

  /// No description provided for @trainingPostRepescageBody.
  ///
  /// In pt, this message translates to:
  /// **'Substituir vs média: «só repescagem» usa apenas as questões da última libertação de erros; «média global» mantém a média de todas as questões já libertadas.'**
  String get trainingPostRepescageBody;

  /// No description provided for @trainingPolicyFinalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Política de nota final'**
  String get trainingPolicyFinalLabel;

  /// No description provided for @trainingPolicyFullAverage.
  ///
  /// In pt, this message translates to:
  /// **'Média global (todas as questões libertadas)'**
  String get trainingPolicyFullAverage;

  /// No description provided for @trainingPolicyRecoveryOnly.
  ///
  /// In pt, this message translates to:
  /// **'Só repescagem (substitui a média global)'**
  String get trainingPolicyRecoveryOnly;

  /// No description provided for @trainingVariantBankTitle.
  ///
  /// In pt, this message translates to:
  /// **'Banco de variantes (repescagem)'**
  String get trainingVariantBankTitle;

  /// No description provided for @trainingVariantBankSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Se as perguntas tiverem o mesmo grupo de variantes no questionário, na repescagem propõe outra pergunta equivalente em vez de repetir a mesma.'**
  String get trainingVariantBankSubtitle;

  /// No description provided for @trainingSavePolicyButton.
  ///
  /// In pt, this message translates to:
  /// **'Guardar política'**
  String get trainingSavePolicyButton;

  /// No description provided for @trainingQuestionnaireTitle.
  ///
  /// In pt, this message translates to:
  /// **'Questionário'**
  String get trainingQuestionnaireTitle;

  /// No description provided for @trainingDefaultQuestionnaireBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação'**
  String get trainingDefaultQuestionnaireBlockTitle;

  /// No description provided for @trainLifecycleDraft.
  ///
  /// In pt, this message translates to:
  /// **'Rascunho'**
  String get trainLifecycleDraft;

  /// No description provided for @trainLifecycleScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Agendado'**
  String get trainLifecycleScheduled;

  /// No description provided for @trainLifecycleInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em curso'**
  String get trainLifecycleInProgress;

  /// No description provided for @trainLifecycleFinished.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get trainLifecycleFinished;

  /// No description provided for @trainLifecycleCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelado'**
  String get trainLifecycleCancelled;

  /// No description provided for @enrollmentStatusWaiting.
  ///
  /// In pt, this message translates to:
  /// **'Em espera'**
  String get enrollmentStatusWaiting;

  /// No description provided for @enrollmentStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get enrollmentStatusActive;

  /// No description provided for @enrollmentStatusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get enrollmentStatusCompleted;

  /// No description provided for @trainingAddQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta'**
  String get trainingAddQuestion;

  /// No description provided for @trainingSaveQuestionnaireApi.
  ///
  /// In pt, this message translates to:
  /// **'Salvar questionário na API'**
  String get trainingSaveQuestionnaireApi;

  /// No description provided for @trainingSnackPolicySaved.
  ///
  /// In pt, this message translates to:
  /// **'Política de nota (repescagem) guardada.'**
  String get trainingSnackPolicySaved;

  /// No description provided for @trainingSnackFromTemplate.
  ///
  /// In pt, this message translates to:
  /// **'Treinamento criado a partir do template oficial.'**
  String get trainingSnackFromTemplate;

  /// No description provided for @trainingPickInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma instituição.'**
  String get trainingPickInstitution;

  /// No description provided for @trainingErrTitle.
  ///
  /// In pt, this message translates to:
  /// **'Informe o título.'**
  String get trainingErrTitle;

  /// No description provided for @trainingErrQuestionCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Cada pergunta precisa de uma opção correta.'**
  String get trainingErrQuestionCorrect;

  /// No description provided for @trainingErrQuestionValid.
  ///
  /// In pt, this message translates to:
  /// **'Adicione ao menos uma pergunta válida com 2+ opções.'**
  String get trainingErrQuestionValid;

  /// No description provided for @trainingSnackQuestionnaireSaved.
  ///
  /// In pt, this message translates to:
  /// **'Questionário salvo.'**
  String get trainingSnackQuestionnaireSaved;

  /// No description provided for @trainingQuestionN.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta {n}'**
  String trainingQuestionN(Object n);

  /// No description provided for @trainingPromptLabel.
  ///
  /// In pt, this message translates to:
  /// **'Enunciado'**
  String get trainingPromptLabel;

  /// No description provided for @trainingOptionsMarkCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Opções (marque a correta)'**
  String get trainingOptionsMarkCorrect;

  /// No description provided for @trainingOptionN.
  ///
  /// In pt, this message translates to:
  /// **'Opção {n}'**
  String trainingOptionN(Object n);

  /// No description provided for @comandoSnackBlockReleased.
  ///
  /// In pt, this message translates to:
  /// **'Próximo bloco liberado (ou já não há blocos pendentes).'**
  String get comandoSnackBlockReleased;

  /// No description provided for @comandoSessionPaused.
  ///
  /// In pt, this message translates to:
  /// **'Sessão pausada para os treinandos.'**
  String get comandoSessionPaused;

  /// No description provided for @comandoSessionResumed.
  ///
  /// In pt, this message translates to:
  /// **'Sessão retomada.'**
  String get comandoSessionResumed;

  /// No description provided for @comandoStatusUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Status: {status}'**
  String comandoStatusUpdate(Object status);

  /// No description provided for @comandoSnackRepescageDone.
  ///
  /// In pt, this message translates to:
  /// **'Repescagem aplicada — participantes podem corrigir respostas erradas.'**
  String get comandoSnackRepescageDone;

  /// No description provided for @comandoActiveTraining.
  ///
  /// In pt, this message translates to:
  /// **'Treinamento ativo'**
  String get comandoActiveTraining;

  /// No description provided for @comandoTrainingStatusHash.
  ///
  /// In pt, this message translates to:
  /// **'Status: {status} · Hash: {hash}'**
  String comandoTrainingStatusHash(Object status, Object hash);

  /// No description provided for @comandoParticipantsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Participantes'**
  String get comandoParticipantsTitle;

  /// No description provided for @comandoParticipantsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por nome ou e-mail'**
  String get comandoParticipantsSearchHint;

  /// No description provided for @comandoParticipantsNoMatch.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum participante corresponde a este filtro.'**
  String get comandoParticipantsNoMatch;

  /// No description provided for @comandoNoParticipants.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum participante inscrito.'**
  String get comandoNoParticipants;

  /// No description provided for @comandoSessionControlTitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle da sessão'**
  String get comandoSessionControlTitle;

  /// No description provided for @comandoRepescageScope.
  ///
  /// In pt, this message translates to:
  /// **'Âmbito da repescagem'**
  String get comandoRepescageScope;

  /// No description provided for @comandoRepescageScopeAll.
  ///
  /// In pt, this message translates to:
  /// **'Todo o treino (todas as respostas erradas)'**
  String get comandoRepescageScopeAll;

  /// No description provided for @comandoBlockDefault.
  ///
  /// In pt, this message translates to:
  /// **'Bloco'**
  String get comandoBlockDefault;

  /// No description provided for @comandoBtnStart.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar'**
  String get comandoBtnStart;

  /// No description provided for @comandoBtnReleaseBlock.
  ///
  /// In pt, this message translates to:
  /// **'Liberar próximo bloco'**
  String get comandoBtnReleaseBlock;

  /// No description provided for @comandoBtnPause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get comandoBtnPause;

  /// No description provided for @comandoBtnResume.
  ///
  /// In pt, this message translates to:
  /// **'Retomar'**
  String get comandoBtnResume;

  /// No description provided for @comandoBtnReschedule.
  ///
  /// In pt, this message translates to:
  /// **'Reagendar'**
  String get comandoBtnReschedule;

  /// No description provided for @comandoBtnClose.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar'**
  String get comandoBtnClose;

  /// No description provided for @comandoRepescageCount.
  ///
  /// In pt, this message translates to:
  /// **'Repescagem ({count})'**
  String comandoRepescageCount(Object count);

  /// No description provided for @comandoHelpFooter.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar libera o questionário para treinandos conectados. Repescagem remove respostas erradas; por bloco, só as desse bloco (etiquetas quando o acerto no bloco está abaixo de 50%).'**
  String get comandoHelpFooter;

  /// No description provided for @comandoOfflineHint.
  ///
  /// In pt, this message translates to:
  /// **'Sem ligação ao servidor. Os comandos da sessão ficam indisponíveis até a API voltar; pode actualizar a lista de treinos quando estiver online.'**
  String get comandoOfflineHint;

  /// No description provided for @instrOfflineHint.
  ///
  /// In pt, this message translates to:
  /// **'Sem ligação ao servidor. Actualize quando a rede voltar; operações que gravam ou exportam ficam indisponíveis até a API responder.'**
  String get instrOfflineHint;

  /// No description provided for @comandoParticipantAnswers.
  ///
  /// In pt, this message translates to:
  /// **'Respostas {answered} / {total} · {status}'**
  String comandoParticipantAnswers(
    Object answered,
    Object total,
    Object status,
  );

  /// No description provided for @comandoHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'Execução ao vivo'**
  String get comandoHeroTitle;

  /// No description provided for @comandoHeroLiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'Ao vivo'**
  String get comandoHeroLiveBadge;

  /// No description provided for @comandoHeroModulePrefix.
  ///
  /// In pt, this message translates to:
  /// **'Módulo:'**
  String get comandoHeroModulePrefix;

  /// No description provided for @comandoStatDurationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get comandoStatDurationLabel;

  /// No description provided for @comandoStatParticipantsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Participantes'**
  String get comandoStatParticipantsLabel;

  /// No description provided for @comandoStatActiveShort.
  ///
  /// In pt, this message translates to:
  /// **'Ativos'**
  String get comandoStatActiveShort;

  /// No description provided for @comandoStatWaitingShort.
  ///
  /// In pt, this message translates to:
  /// **'Em espera'**
  String get comandoStatWaitingShort;

  /// No description provided for @comandoDurationPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'—'**
  String get comandoDurationPlaceholder;

  /// No description provided for @comandoProgressByBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Progresso por bloco'**
  String get comandoProgressByBlockTitle;

  /// No description provided for @comandoColBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bloco'**
  String get comandoColBlockTitle;

  /// No description provided for @comandoColState.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get comandoColState;

  /// No description provided for @comandoColCompletion.
  ///
  /// In pt, this message translates to:
  /// **'Conclusão'**
  String get comandoColCompletion;

  /// No description provided for @comandoColAccuracy.
  ///
  /// In pt, this message translates to:
  /// **'Precisão'**
  String get comandoColAccuracy;

  /// No description provided for @comandoBlockStateReleased.
  ///
  /// In pt, this message translates to:
  /// **'Liberto'**
  String get comandoBlockStateReleased;

  /// No description provided for @comandoBlockStatePending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get comandoBlockStatePending;

  /// No description provided for @comandoDeckSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Inicie, pause ou encerre a sessão em tempo real.'**
  String get comandoDeckSubtitle;

  /// No description provided for @comandoDeckBadgeRunning.
  ///
  /// In pt, this message translates to:
  /// **'Em curso'**
  String get comandoDeckBadgeRunning;

  /// No description provided for @comandoDeckBadgePaused.
  ///
  /// In pt, this message translates to:
  /// **'Pausado'**
  String get comandoDeckBadgePaused;

  /// No description provided for @comandoDeckBadgeScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Agendado'**
  String get comandoDeckBadgeScheduled;

  /// No description provided for @comandoDeckBadgeFinished.
  ///
  /// In pt, this message translates to:
  /// **'Encerrado'**
  String get comandoDeckBadgeFinished;

  /// No description provided for @credSnackInstitutionCreated.
  ///
  /// In pt, this message translates to:
  /// **'Instituição criada.'**
  String get credSnackInstitutionCreated;

  /// No description provided for @credTitleInstitutions.
  ///
  /// In pt, this message translates to:
  /// **'Instituições'**
  String get credTitleInstitutions;

  /// No description provided for @credIntroInstitutions.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre hospitais ou unidades para vincular aos treinamentos.'**
  String get credIntroInstitutions;

  /// No description provided for @credFieldInstitutionName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da instituição'**
  String get credFieldInstitutionName;

  /// No description provided for @credFieldCnpjUnique.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ (único)'**
  String get credFieldCnpjUnique;

  /// No description provided for @credBtnRegisterInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar instituição'**
  String get credBtnRegisterInstitution;

  /// No description provided for @credListedCount.
  ///
  /// In pt, this message translates to:
  /// **'Cadastradas ({count})'**
  String credListedCount(Object count);

  /// No description provided for @credDoubleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Credenciamento duplo'**
  String get credDoubleTitle;

  /// No description provided for @credDoubleIntro.
  ///
  /// In pt, this message translates to:
  /// **'Vínculo com instituição e homologação pelo fabricante.'**
  String get credDoubleIntro;

  /// No description provided for @credApplyInstitutionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pedir vínculo à instituição'**
  String get credApplyInstitutionLabel;

  /// No description provided for @credBtnRequestInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Solicitar vínculo institucional'**
  String get credBtnRequestInstitution;

  /// No description provided for @credApplyManufacturerLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pedir homologação ao fabricante'**
  String get credApplyManufacturerLabel;

  /// No description provided for @credBtnRequestManufacturer.
  ///
  /// In pt, this message translates to:
  /// **'Solicitar ao fabricante'**
  String get credBtnRequestManufacturer;

  /// No description provided for @credMyLinksTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meus vínculos'**
  String get credMyLinksTitle;

  /// No description provided for @credMyLinksInstitutionsHeader.
  ///
  /// In pt, this message translates to:
  /// **'Instituições'**
  String get credMyLinksInstitutionsHeader;

  /// No description provided for @credNoInstitutionalLink.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum vínculo institucional.'**
  String get credNoInstitutionalLink;

  /// No description provided for @credMyLinksManufacturersHeader.
  ///
  /// In pt, this message translates to:
  /// **'Fabricantes'**
  String get credMyLinksManufacturersHeader;

  /// No description provided for @credNoManufacturerHomologation.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma homologação junto a fabricantes.'**
  String get credNoManufacturerHomologation;

  /// No description provided for @credQueueInstTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedidos de vínculo (gestor)'**
  String get credQueueInstTitle;

  /// No description provided for @credQueueInstBody.
  ///
  /// In pt, this message translates to:
  /// **'Instrutores que pediram vínculo com a sua instituição. O estado «Pendente» desaparece da fila após decidir.'**
  String get credQueueInstBody;

  /// No description provided for @credQueueManuTitle.
  ///
  /// In pt, this message translates to:
  /// **'Homologações pendentes (fabricante)'**
  String get credQueueManuTitle;

  /// No description provided for @credQueueManuBody.
  ///
  /// In pt, this message translates to:
  /// **'Homologação de instrutores junto do fabricante. Verifique o endosso da instituição antes de aprovar.'**
  String get credQueueManuBody;

  /// No description provided for @credBtnApprove.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar'**
  String get credBtnApprove;

  /// No description provided for @credBtnSuspend.
  ///
  /// In pt, this message translates to:
  /// **'Suspender'**
  String get credBtnSuspend;

  /// No description provided for @credBtnReactivateHomolog.
  ///
  /// In pt, this message translates to:
  /// **'Reactivar'**
  String get credBtnReactivateHomolog;

  /// No description provided for @credStatusSuspended.
  ///
  /// In pt, this message translates to:
  /// **'Suspenso'**
  String get credStatusSuspended;

  /// No description provided for @credBtnReject.
  ///
  /// In pt, this message translates to:
  /// **'Recusar'**
  String get credBtnReject;

  /// No description provided for @credEndorsementWith.
  ///
  /// In pt, this message translates to:
  /// **'Endosso institucional: {name}'**
  String credEndorsementWith(Object name);

  /// No description provided for @credEndorsementPending.
  ///
  /// In pt, this message translates to:
  /// **'Endosso institucional: pendente'**
  String get credEndorsementPending;

  /// No description provided for @credSnackRequestSent.
  ///
  /// In pt, this message translates to:
  /// **'Pedido enviado.'**
  String get credSnackRequestSent;

  /// No description provided for @credSnackRequestManufacturerSent.
  ///
  /// In pt, this message translates to:
  /// **'Pedido enviado ao fabricante.'**
  String get credSnackRequestManufacturerSent;

  /// No description provided for @credStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get credStatusPending;

  /// No description provided for @credStatusApproved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado'**
  String get credStatusApproved;

  /// No description provided for @credStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Recusado'**
  String get credStatusRejected;

  /// No description provided for @credFeePaid.
  ///
  /// In pt, this message translates to:
  /// **'Taxa indicada como paga'**
  String get credFeePaid;

  /// No description provided for @credFeePending.
  ///
  /// In pt, this message translates to:
  /// **'Taxa pendente (se aplicável)'**
  String get credFeePending;

  /// No description provided for @trainReqLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao carregar.'**
  String get trainReqLoadFailed;

  /// No description provided for @trainReqSnackUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Pedido actualizado.'**
  String get trainReqSnackUpdated;

  /// No description provided for @trainReqUseOrangeBanner.
  ///
  /// In pt, this message translates to:
  /// **'Use o aviso laranja no topo para vincular a sua instituição.'**
  String get trainReqUseOrangeBanner;

  /// No description provided for @trainReqIntro.
  ///
  /// In pt, this message translates to:
  /// **'Aprove, designe um instrutor credenciado e associe ao treino realizado quando existir.'**
  String get trainReqIntro;

  /// No description provided for @trainReqKanbanColumnQueue.
  ///
  /// In pt, this message translates to:
  /// **'Fila'**
  String get trainReqKanbanColumnQueue;

  /// No description provided for @trainReqKanbanColumnQueueHint.
  ///
  /// In pt, this message translates to:
  /// **'Pendente · Aprovado'**
  String get trainReqKanbanColumnQueueHint;

  /// No description provided for @trainReqKanbanColumnScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Agendado'**
  String get trainReqKanbanColumnScheduled;

  /// No description provided for @trainReqKanbanColumnScheduledHint.
  ///
  /// In pt, this message translates to:
  /// **'Com instrutor designado'**
  String get trainReqKanbanColumnScheduledHint;

  /// No description provided for @trainReqKanbanColumnClosed.
  ///
  /// In pt, this message translates to:
  /// **'Encerrados'**
  String get trainReqKanbanColumnClosed;

  /// No description provided for @trainReqKanbanColumnClosedHint.
  ///
  /// In pt, this message translates to:
  /// **'Concluído · Recusado'**
  String get trainReqKanbanColumnClosedHint;

  /// No description provided for @trainReqEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pedido de treino.'**
  String get trainReqEmpty;

  /// No description provided for @trainReqReasonLine.
  ///
  /// In pt, this message translates to:
  /// **'Motivo: {text}'**
  String trainReqReasonLine(Object text);

  /// No description provided for @trainReqPriorityLine.
  ///
  /// In pt, this message translates to:
  /// **'Prioridade: {text}'**
  String trainReqPriorityLine(Object text);

  /// No description provided for @trainReqParkLine.
  ///
  /// In pt, this message translates to:
  /// **'Parque: {name} ({detail})'**
  String trainReqParkLine(Object name, Object detail);

  /// No description provided for @trainReqPreferredDates.
  ///
  /// In pt, this message translates to:
  /// **'Datas preferidas: {desired} · limite {limit}'**
  String trainReqPreferredDates(Object desired, Object limit);

  /// No description provided for @trainReqNotesLine.
  ///
  /// In pt, this message translates to:
  /// **'Notas: {text}'**
  String trainReqNotesLine(Object text);

  /// No description provided for @trainReqFieldStatus.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get trainReqFieldStatus;

  /// No description provided for @trainReqStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get trainReqStatusPending;

  /// No description provided for @trainReqStatusApproved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado'**
  String get trainReqStatusApproved;

  /// No description provided for @trainReqStatusScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Agendado'**
  String get trainReqStatusScheduled;

  /// No description provided for @trainReqStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Recusado'**
  String get trainReqStatusRejected;

  /// No description provided for @trainReqStatusFulfilled.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get trainReqStatusFulfilled;

  /// No description provided for @trainReqFieldAssignedInstructor.
  ///
  /// In pt, this message translates to:
  /// **'Instrutor designado'**
  String get trainReqFieldAssignedInstructor;

  /// No description provided for @trainReqFieldFulfilledTraining.
  ///
  /// In pt, this message translates to:
  /// **'Treino realizado'**
  String get trainReqFieldFulfilledTraining;

  /// No description provided for @trainReqDashNone.
  ///
  /// In pt, this message translates to:
  /// **'—'**
  String get trainReqDashNone;

  /// No description provided for @trainReqLinkedTraining.
  ///
  /// In pt, this message translates to:
  /// **'Vinculado: {title} · hash {hash}'**
  String trainReqLinkedTraining(Object title, Object hash);

  /// No description provided for @trainReqBtnSaveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Guardar alterações'**
  String get trainReqBtnSaveChanges;

  /// No description provided for @trainReqBatchCheckboxLabel.
  ///
  /// In pt, this message translates to:
  /// **'Seleccionar para agendar em lote'**
  String get trainReqBatchCheckboxLabel;

  /// No description provided for @trainReqBatchToolbarSelected.
  ///
  /// In pt, this message translates to:
  /// **'{count} seleccionados'**
  String trainReqBatchToolbarSelected(int count);

  /// No description provided for @trainReqBatchToolbarClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar selecção'**
  String get trainReqBatchToolbarClear;

  /// No description provided for @trainReqBatchToolbarSchedule.
  ///
  /// In pt, this message translates to:
  /// **'Agendar em lote'**
  String get trainReqBatchToolbarSchedule;

  /// No description provided for @trainReqBatchDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Agendar pedidos em lote'**
  String get trainReqBatchDialogTitle;

  /// No description provided for @trainReqBatchDialogBody.
  ///
  /// In pt, this message translates to:
  /// **'Defina o instrutor para {count} pedido(s) na fila (pendente ou aprovado).'**
  String trainReqBatchDialogBody(int count);

  /// No description provided for @trainReqBatchSelectInstructorPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o instrutor…'**
  String get trainReqBatchSelectInstructorPlaceholder;

  /// No description provided for @trainReqBatchConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Agendar'**
  String get trainReqBatchConfirm;

  /// No description provided for @trainReqBatchSnackDone.
  ///
  /// In pt, this message translates to:
  /// **'{count} pedido(s) agendado(s).'**
  String trainReqBatchSnackDone(int count);

  /// No description provided for @trainReqBatchSnackNoneEligible.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pedido elegível na selecção (use pendente ou aprovado na fila).'**
  String get trainReqBatchSnackNoneEligible;

  /// No description provided for @trainReqBatchNoInstructors.
  ///
  /// In pt, this message translates to:
  /// **'Não há instrutores credenciados — aprove credenciais primeiro.'**
  String get trainReqBatchNoInstructors;

  /// No description provided for @parkSnackPickCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um modelo do catálogo.'**
  String get parkSnackPickCatalog;

  /// No description provided for @parkSnackUnitRegisteredPending.
  ///
  /// In pt, this message translates to:
  /// **'Unidade registada (pendente).'**
  String get parkSnackUnitRegisteredPending;

  /// No description provided for @parkBannerLinkInstitutionFirst.
  ///
  /// In pt, this message translates to:
  /// **'Associe primeiro a sua instituição no banner acima.'**
  String get parkBannerLinkInstitutionFirst;

  /// No description provided for @parkIntro.
  ///
  /// In pt, this message translates to:
  /// **'Cada unidade replica um modelo do catálogo do fabricante. Estado inicial: pendente; activo quando em uso homologado.'**
  String get parkIntro;

  /// No description provided for @parkSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar nome, modelo, setor ou fabricante (no catálogo)'**
  String get parkSearchHint;

  /// No description provided for @parkFilterByState.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por estado'**
  String get parkFilterByState;

  /// No description provided for @parkFilterChipAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get parkFilterChipAll;

  /// No description provided for @parkFilterChipPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes'**
  String get parkFilterChipPending;

  /// No description provided for @parkFilterChipActive.
  ///
  /// In pt, this message translates to:
  /// **'Activos'**
  String get parkFilterChipActive;

  /// No description provided for @parkFilterByCategory.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por categoria'**
  String get parkFilterByCategory;

  /// No description provided for @parkFilterChipAllCategories.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get parkFilterChipAllCategories;

  /// No description provided for @parkSectionAddUnit.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar unidade'**
  String get parkSectionAddUnit;

  /// No description provided for @parkEmptyCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Sem modelos no catálogo de fabricantes — ainda não há equipamentos para vincular.'**
  String get parkEmptyCatalog;

  /// No description provided for @parkCatalogDropdownHint.
  ///
  /// In pt, this message translates to:
  /// **'Modelo do catálogo'**
  String get parkCatalogDropdownHint;

  /// No description provided for @parkFieldSectorOptional.
  ///
  /// In pt, this message translates to:
  /// **'Setor / local (opcional)'**
  String get parkFieldSectorOptional;

  /// No description provided for @parkFieldSectorHintExample.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: UCI B, Bloco 3'**
  String get parkFieldSectorHintExample;

  /// No description provided for @parkBtnRegisterUnit.
  ///
  /// In pt, this message translates to:
  /// **'Registar unidade'**
  String get parkBtnRegisterUnit;

  /// No description provided for @parkUnitsCount.
  ///
  /// In pt, this message translates to:
  /// **'Unidades ({count})'**
  String parkUnitsCount(Object count);

  /// No description provided for @parkEmptyPark.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma unidade no parque.'**
  String get parkEmptyPark;

  /// No description provided for @parkEquipmentFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Equipamento'**
  String get parkEquipmentFallbackName;

  /// No description provided for @parkBtnActivate.
  ///
  /// In pt, this message translates to:
  /// **'Activar'**
  String get parkBtnActivate;

  /// No description provided for @parkStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get parkStatusPending;

  /// No description provided for @parkStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Activo'**
  String get parkStatusActive;

  /// No description provided for @endorsSnackRecorded.
  ///
  /// In pt, this message translates to:
  /// **'Endosso registado.'**
  String get endorsSnackRecorded;

  /// No description provided for @endorsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pedido de homologação aguarda endosso.'**
  String get endorsEmpty;

  /// No description provided for @endorsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Confirme que o instrutor está credenciado na sua instituição perante o pedido de homologação junto do fabricante.'**
  String get endorsIntro;

  /// No description provided for @endorsManufacturerFallback.
  ///
  /// In pt, this message translates to:
  /// **'Fabricante'**
  String get endorsManufacturerFallback;

  /// No description provided for @endorsInstructorLine.
  ///
  /// In pt, this message translates to:
  /// **'Instrutor: {name}'**
  String endorsInstructorLine(Object name);

  /// No description provided for @endorsBtnEndorse.
  ///
  /// In pt, this message translates to:
  /// **'Endossar'**
  String get endorsBtnEndorse;

  /// No description provided for @fluxRevSnackStatusUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Estado actualizado.'**
  String get fluxRevSnackStatusUpdated;

  /// No description provided for @fluxRevEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum fabricante em análise.'**
  String get fluxRevEmpty;

  /// No description provided for @fluxRevQueueTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fila de validação'**
  String get fluxRevQueueTitle;

  /// No description provided for @fluxRevIntro.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar torna o fabricante visível no catálogo para credenciação; recusar ou pedir informações devolve o fluxo ao fabricante.'**
  String get fluxRevIntro;

  /// No description provided for @fluxRevIdLine.
  ///
  /// In pt, this message translates to:
  /// **'ID {id}'**
  String fluxRevIdLine(Object id);

  /// No description provided for @fluxRevCnpjLine.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ: {value}'**
  String fluxRevCnpjLine(Object value);

  /// No description provided for @fluxRevSupportLine.
  ///
  /// In pt, this message translates to:
  /// **'Suporte: {email}'**
  String fluxRevSupportLine(Object email);

  /// No description provided for @fluxRevBtnRequestInfo.
  ///
  /// In pt, this message translates to:
  /// **'Pedir informações'**
  String get fluxRevBtnRequestInfo;

  /// No description provided for @mfgLoadFailedData.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao carregar dados.'**
  String get mfgLoadFailedData;

  /// No description provided for @mfgAreaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fabricante'**
  String get mfgAreaTitle;

  /// No description provided for @mfgNavHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get mfgNavHome;

  /// No description provided for @mfgNavCompany.
  ///
  /// In pt, this message translates to:
  /// **'Empresa'**
  String get mfgNavCompany;

  /// No description provided for @mfgNavProducts.
  ///
  /// In pt, this message translates to:
  /// **'Produtos'**
  String get mfgNavProducts;

  /// No description provided for @mfgNavOperations.
  ///
  /// In pt, this message translates to:
  /// **'Operações'**
  String get mfgNavOperations;

  /// No description provided for @mfgNavHomologations.
  ///
  /// In pt, this message translates to:
  /// **'Homologações'**
  String get mfgNavHomologations;

  /// No description provided for @mfgNavAnalytics.
  ///
  /// In pt, this message translates to:
  /// **'Análises'**
  String get mfgNavAnalytics;

  /// No description provided for @mfgAnalyticsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Análises agregadas'**
  String get mfgAnalyticsTitle;

  /// No description provided for @mfgAnalyticsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Filtre por instituição, equipamento ligado ao treino ou período de criação dos treinos. Dados agregados, sem identificação individual (LGPD).'**
  String get mfgAnalyticsIntro;

  /// No description provided for @mfgAnalyticsFilterInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Instituição'**
  String get mfgAnalyticsFilterInstitution;

  /// No description provided for @mfgAnalyticsFilterEquipment.
  ///
  /// In pt, this message translates to:
  /// **'Equipamento (no treino)'**
  String get mfgAnalyticsFilterEquipment;

  /// No description provided for @mfgAnalyticsDateFrom.
  ///
  /// In pt, this message translates to:
  /// **'Treinos criados desde (AAAA-MM-DD)'**
  String get mfgAnalyticsDateFrom;

  /// No description provided for @mfgAnalyticsDateTo.
  ///
  /// In pt, this message translates to:
  /// **'Treinos criados até (AAAA-MM-DD)'**
  String get mfgAnalyticsDateTo;

  /// No description provided for @mfgAnalyticsApply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar filtros'**
  String get mfgAnalyticsApply;

  /// No description provided for @mfgAnalyticsReset.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get mfgAnalyticsReset;

  /// No description provided for @mfgAnalyticsAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas/os'**
  String get mfgAnalyticsAll;

  /// No description provided for @mfgAnalyticsSectionInstitutions.
  ///
  /// In pt, this message translates to:
  /// **'Por instituição'**
  String get mfgAnalyticsSectionInstitutions;

  /// No description provided for @mfgAnalyticsSectionEquipment.
  ///
  /// In pt, this message translates to:
  /// **'Por equipamento'**
  String get mfgAnalyticsSectionEquipment;

  /// No description provided for @mfgAnalyticsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados para estes filtros.'**
  String get mfgAnalyticsEmpty;

  /// No description provided for @mfgAnalyticsLoading.
  ///
  /// In pt, this message translates to:
  /// **'A carregar…'**
  String get mfgAnalyticsLoading;

  /// No description provided for @mfgAnalyticsBreakdownSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{trainings} treinos · inscr.: {enr} · concl.: {done} · taxa: {rate} · média: {avg}'**
  String mfgAnalyticsBreakdownSubtitle(
    int trainings,
    int enr,
    int done,
    String rate,
    String avg,
  );

  /// No description provided for @mfgAnalyticsSectionMonthlyTrend.
  ///
  /// In pt, this message translates to:
  /// **'Tendência mensal (combinada)'**
  String get mfgAnalyticsSectionMonthlyTrend;

  /// No description provided for @mfgAnalyticsMonthlyTrendIntro.
  ///
  /// In pt, this message translates to:
  /// **'Mesmo eixo temporal (AAAA-MM): inscrições por COALESCE(joined_at, created_at) e conclusões por completed_at (UTC). Barras normalizadas ao máximo de cada métrica.'**
  String get mfgAnalyticsMonthlyTrendIntro;

  /// No description provided for @mfgAnalyticsMonthlyTrendEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados mensais no período filtrado.'**
  String get mfgAnalyticsMonthlyTrendEmpty;

  /// No description provided for @mfgAnalyticsTrendLegendEnroll.
  ///
  /// In pt, this message translates to:
  /// **'Inscrições'**
  String get mfgAnalyticsTrendLegendEnroll;

  /// No description provided for @mfgAnalyticsTrendLegendComplete.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas'**
  String get mfgAnalyticsTrendLegendComplete;

  /// No description provided for @mfgHomologRequestedAt.
  ///
  /// In pt, this message translates to:
  /// **'Registado: {date}'**
  String mfgHomologRequestedAt(String date);

  /// No description provided for @mfgHomologEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pedido de credenciamento neste momento.'**
  String get mfgHomologEmpty;

  /// No description provided for @mfgHomologFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get mfgHomologFilterAll;

  /// No description provided for @mfgHomologFilterPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes'**
  String get mfgHomologFilterPending;

  /// No description provided for @mfgHomologFilterApproved.
  ///
  /// In pt, this message translates to:
  /// **'Aprovados'**
  String get mfgHomologFilterApproved;

  /// No description provided for @mfgHomologFilterRejected.
  ///
  /// In pt, this message translates to:
  /// **'Recusados'**
  String get mfgHomologFilterRejected;

  /// No description provided for @mfgHomologFilterSuspended.
  ///
  /// In pt, this message translates to:
  /// **'Suspensos'**
  String get mfgHomologFilterSuspended;

  /// No description provided for @mfgSnackHomologUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Pedido de homologação atualizado.'**
  String get mfgSnackHomologUpdated;

  /// No description provided for @mfgNavGroupSummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo e cadastro'**
  String get mfgNavGroupSummary;

  /// No description provided for @mfgNavGroupOffer.
  ///
  /// In pt, this message translates to:
  /// **'Oferta e rotina'**
  String get mfgNavGroupOffer;

  /// No description provided for @mfgDashSummaryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo agregado'**
  String get mfgDashSummaryTitle;

  /// No description provided for @mfgDashSummaryIntro.
  ///
  /// In pt, this message translates to:
  /// **'Treinos e inscrições ligados a este fabricante — dados agregados (LGPD).'**
  String get mfgDashSummaryIntro;

  /// No description provided for @mfgDashMonthlyTrendTitle.
  ///
  /// In pt, this message translates to:
  /// **'Evolução recente (mensal)'**
  String get mfgDashMonthlyTrendTitle;

  /// No description provided for @mfgDashMonthlyTrendIntro.
  ///
  /// In pt, this message translates to:
  /// **'Até os últimos 6 meses com dados: inscrições vs. conclusões (mesma lógica que em Análises).'**
  String get mfgDashMonthlyTrendIntro;

  /// No description provided for @mfgDashOpenAnalytics.
  ///
  /// In pt, this message translates to:
  /// **'Abrir análises'**
  String get mfgDashOpenAnalytics;

  /// No description provided for @mfgDashSummaryUnavailableTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo agregado indisponível'**
  String get mfgDashSummaryUnavailableTitle;

  /// No description provided for @mfgDashSummaryUnavailableBody.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o resumo neste momento. Tente novamente ou abra Análises.'**
  String get mfgDashSummaryUnavailableBody;

  /// No description provided for @mfgSnackValidationRequested.
  ///
  /// In pt, this message translates to:
  /// **'Pedido de validação enviado. A nossa equipa irá analisar.'**
  String get mfgSnackValidationRequested;

  /// No description provided for @mfgSeasonNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova temporada'**
  String get mfgSeasonNewTitle;

  /// No description provided for @mfgFieldName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get mfgFieldName;

  /// No description provided for @mfgFieldSeasonStart.
  ///
  /// In pt, this message translates to:
  /// **'Início (AAAA-MM-DD)'**
  String get mfgFieldSeasonStart;

  /// No description provided for @mfgFieldSeasonEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim (AAAA-MM-DD)'**
  String get mfgFieldSeasonEnd;

  /// No description provided for @mfgFieldTargetTrainingsOptional.
  ///
  /// In pt, this message translates to:
  /// **'Meta treinos encerrados (opcional)'**
  String get mfgFieldTargetTrainingsOptional;

  /// No description provided for @mfgBtnCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get mfgBtnCancel;

  /// No description provided for @mfgBtnClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get mfgBtnClose;

  /// No description provided for @mfgBtnCreate.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get mfgBtnCreate;

  /// No description provided for @mfgSeasonCreatedSnack.
  ///
  /// In pt, this message translates to:
  /// **'Temporada criada e ranking atualizado.'**
  String get mfgSeasonCreatedSnack;

  /// No description provided for @mfgSeasonCreateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar.'**
  String get mfgSeasonCreateFailed;

  /// No description provided for @mfgSeasonRankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ranking da temporada'**
  String get mfgSeasonRankingTitle;

  /// No description provided for @mfgSeasonTargetLine.
  ///
  /// In pt, this message translates to:
  /// **'Meta: {count} treinos encerrados'**
  String mfgSeasonTargetLine(Object count);

  /// No description provided for @mfgSeasonNoClosedTrainings.
  ///
  /// In pt, this message translates to:
  /// **'Sem treinos encerrados no período (com este fabricante).'**
  String get mfgSeasonNoClosedTrainings;

  /// No description provided for @mfgLeaderboardLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao carregar ranking.'**
  String get mfgLeaderboardLoadFailed;

  /// No description provided for @mfgSnackRankingRecomputed.
  ///
  /// In pt, this message translates to:
  /// **'Ranking recalculado.'**
  String get mfgSnackRankingRecomputed;

  /// No description provided for @mfgPointsTrainings.
  ///
  /// In pt, this message translates to:
  /// **'{count} treinos'**
  String mfgPointsTrainings(Object count);

  /// No description provided for @mfgPrizeNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo prémio (registo)'**
  String get mfgPrizeNewTitle;

  /// No description provided for @mfgFieldTitle.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get mfgFieldTitle;

  /// No description provided for @mfgFieldDescriptionOptional.
  ///
  /// In pt, this message translates to:
  /// **'Descrição (opcional)'**
  String get mfgFieldDescriptionOptional;

  /// No description provided for @mfgFieldSortOptional.
  ///
  /// In pt, this message translates to:
  /// **'Ordem (opcional, menor = primeiro)'**
  String get mfgFieldSortOptional;

  /// No description provided for @mfgBtnSave.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get mfgBtnSave;

  /// No description provided for @mfgPrizeSavedSnack.
  ///
  /// In pt, this message translates to:
  /// **'Prémio registado.'**
  String get mfgPrizeSavedSnack;

  /// No description provided for @mfgPrizeSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível guardar.'**
  String get mfgPrizeSaveFailed;

  /// No description provided for @mfgPrizeDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover prémio?'**
  String get mfgPrizeDeleteTitle;

  /// No description provided for @mfgPrizeDeleteBody.
  ///
  /// In pt, this message translates to:
  /// **'O registo será apagado. Isto não afilia pagamentos (MVP).'**
  String get mfgPrizeDeleteBody;

  /// No description provided for @mfgBtnAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get mfgBtnAdd;

  /// No description provided for @mfgBtnRemove.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get mfgBtnRemove;

  /// No description provided for @mfgSnackRemoved.
  ///
  /// In pt, this message translates to:
  /// **'Removido.'**
  String get mfgSnackRemoved;

  /// No description provided for @mfgSnackProfileUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Perfil atualizado.'**
  String get mfgSnackProfileUpdated;

  /// No description provided for @mfgSnackVersionDraftHint.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o novo modelo e toque em «Adicionar ao catálogo» (origem #{parentId}).'**
  String mfgSnackVersionDraftHint(Object parentId);

  /// No description provided for @mfgSnackNameModelRequired.
  ///
  /// In pt, this message translates to:
  /// **'Nome e modelo são obrigatórios.'**
  String get mfgSnackNameModelRequired;

  /// No description provided for @mfgSnackEquipmentCreated.
  ///
  /// In pt, this message translates to:
  /// **'Equipamento criado.'**
  String get mfgSnackEquipmentCreated;

  /// No description provided for @mfgSnackNewVersionRegistered.
  ///
  /// In pt, this message translates to:
  /// **'Nova versão registada.'**
  String get mfgSnackNewVersionRegistered;

  /// No description provided for @mfgSnackFileReadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler o ficheiro.'**
  String get mfgSnackFileReadError;

  /// No description provided for @mfgSnackDocumentUploaded.
  ///
  /// In pt, this message translates to:
  /// **'Documento enviado.'**
  String get mfgSnackDocumentUploaded;

  /// No description provided for @mfgSnackUploadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao enviar.'**
  String get mfgSnackUploadFailed;

  /// No description provided for @mfgSnackDocumentRemoved.
  ///
  /// In pt, this message translates to:
  /// **'Documento removido.'**
  String get mfgSnackDocumentRemoved;

  /// No description provided for @mfgSnackFileSaved.
  ///
  /// In pt, this message translates to:
  /// **'Guardado: {name}'**
  String mfgSnackFileSaved(Object name);

  /// No description provided for @mfgSnackDownloadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao descarregar.'**
  String get mfgSnackDownloadFailed;

  /// No description provided for @mfgFileFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Ficheiro'**
  String get mfgFileFallbackName;

  /// No description provided for @mfgSnackOfficialTitleRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o título do treinamento oficial.'**
  String get mfgSnackOfficialTitleRequired;

  /// No description provided for @mfgSnackTemplateCreated.
  ///
  /// In pt, this message translates to:
  /// **'Template criado. Toque em «Editar questionário» na lista abaixo para o conteúdo oficial.'**
  String get mfgSnackTemplateCreated;

  /// No description provided for @mfgSeasonsSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Temporadas e ranking'**
  String get mfgSeasonsSectionTitle;

  /// No description provided for @mfgSeasonsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Pontos = treinos encerrados (estado «finished») ligados a este fabricante, no período da temporada. Atualização diária automática ou manual.'**
  String get mfgSeasonsIntro;

  /// No description provided for @mfgSeasonsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma temporada — crie uma para acompanhar instrutores por semestre ou ciclo.'**
  String get mfgSeasonsEmpty;

  /// No description provided for @mfgSeasonMetaSuffix.
  ///
  /// In pt, this message translates to:
  /// **' · meta {count}'**
  String mfgSeasonMetaSuffix(Object count);

  /// No description provided for @mfgTooltipViewLeaderboard.
  ///
  /// In pt, this message translates to:
  /// **'Ver ranking'**
  String get mfgTooltipViewLeaderboard;

  /// No description provided for @mfgTooltipRecompute.
  ///
  /// In pt, this message translates to:
  /// **'Recalcular'**
  String get mfgTooltipRecompute;

  /// No description provided for @mfgPrizesSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Prémios (registo)'**
  String get mfgPrizesSectionTitle;

  /// No description provided for @mfgPrizesIntro.
  ///
  /// In pt, this message translates to:
  /// **'Descrição informativa para campanhas ou reconhecimentos — sem pagamento integrado no MVP.'**
  String get mfgPrizesIntro;

  /// No description provided for @mfgPrizesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum prémio registado.'**
  String get mfgPrizesEmpty;

  /// No description provided for @mfgDocumentsSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Documentos para validação'**
  String get mfgDocumentsSectionTitle;

  /// No description provided for @mfgDocumentsIntro.
  ///
  /// In pt, this message translates to:
  /// **'PDF ou imagem até 12 MB. O servidor usa o disco configurado (local ou S3 via FILESYSTEM_DISK); envie manuais ou anexos para homologação.'**
  String get mfgDocumentsIntro;

  /// No description provided for @mfgOpsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar épocas, prémios e documentos enviados'**
  String get mfgOpsSearchHint;

  /// No description provided for @mfgOpsServerFilterHint.
  ///
  /// In pt, this message translates to:
  /// **'Filtro no servidor; os resultados actualizam pouco depois de parar de escrever.'**
  String get mfgOpsServerFilterHint;

  /// No description provided for @mfgOpsSublistNoMatch.
  ///
  /// In pt, this message translates to:
  /// **'Sem resultados neste bloco.'**
  String get mfgOpsSublistNoMatch;

  /// No description provided for @mfgOpsLoadMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregar mais'**
  String get mfgOpsLoadMore;

  /// No description provided for @mfgDocKindOptional.
  ///
  /// In pt, this message translates to:
  /// **'Tipo (opcional)'**
  String get mfgDocKindOptional;

  /// No description provided for @mfgDocKindHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: manual, certificado, ficha técnica'**
  String get mfgDocKindHint;

  /// No description provided for @mfgDocNotesOptional.
  ///
  /// In pt, this message translates to:
  /// **'Notas (opcional)'**
  String get mfgDocNotesOptional;

  /// No description provided for @mfgBtnSendFile.
  ///
  /// In pt, this message translates to:
  /// **'Enviar ficheiro'**
  String get mfgBtnSendFile;

  /// No description provided for @mfgDocumentsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum documento enviado.'**
  String get mfgDocumentsEmpty;

  /// No description provided for @mfgTooltipDownload.
  ///
  /// In pt, this message translates to:
  /// **'Descarregar'**
  String get mfgTooltipDownload;

  /// No description provided for @mfgOfficialTrainingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Treinamentos oficiais (templates)'**
  String get mfgOfficialTrainingTitle;

  /// No description provided for @mfgOfficialTrainingIntro.
  ///
  /// In pt, this message translates to:
  /// **'Templates sem instituição; instrutores homologados instanciam para o hospital.'**
  String get mfgOfficialTrainingIntro;

  /// No description provided for @mfgTemplateTitleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Título do template'**
  String get mfgTemplateTitleLabel;

  /// No description provided for @mfgTemplateTitleHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Operação básica do ventilador X'**
  String get mfgTemplateTitleHint;

  /// No description provided for @mfgBtnCreateTemplateDraft.
  ///
  /// In pt, this message translates to:
  /// **'Criar template (rascunho)'**
  String get mfgBtnCreateTemplateDraft;

  /// No description provided for @mfgYourTemplates.
  ///
  /// In pt, this message translates to:
  /// **'Seus templates'**
  String get mfgYourTemplates;

  /// No description provided for @mfgTemplatesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum template ainda. Crie um acima.'**
  String get mfgTemplatesEmpty;

  /// No description provided for @mfgTplSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar título do template'**
  String get mfgTplSearchHint;

  /// No description provided for @mfgTplFilterStatusLabel.
  ///
  /// In pt, this message translates to:
  /// **'Estado do template'**
  String get mfgTplFilterStatusLabel;

  /// No description provided for @mfgTplSortLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar lista'**
  String get mfgTplSortLabel;

  /// No description provided for @mfgTplSortUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Actualizados recentemente'**
  String get mfgTplSortUpdated;

  /// No description provided for @mfgTplSortTitleAsc.
  ///
  /// In pt, this message translates to:
  /// **'Título (A–Z)'**
  String get mfgTplSortTitleAsc;

  /// No description provided for @mfgTplSortTitleDesc.
  ///
  /// In pt, this message translates to:
  /// **'Título (Z–A)'**
  String get mfgTplSortTitleDesc;

  /// No description provided for @mfgTplSortStatus.
  ///
  /// In pt, this message translates to:
  /// **'Por estado'**
  String get mfgTplSortStatus;

  /// No description provided for @mfgTplRowUpdatedAt.
  ///
  /// In pt, this message translates to:
  /// **'Actualizado: {date}'**
  String mfgTplRowUpdatedAt(String date);

  /// No description provided for @mfgTplListResultCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} template(s) listado(s) (até 80).'**
  String mfgTplListResultCount(Object count);

  /// No description provided for @mfgTplClearFilters.
  ///
  /// In pt, this message translates to:
  /// **'Limpar filtros'**
  String get mfgTplClearFilters;

  /// No description provided for @mfgTplNoMatches.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum template corresponde aos filtros actuais.'**
  String get mfgTplNoMatches;

  /// No description provided for @mfgTrainingFallbackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Treino'**
  String get mfgTrainingFallbackTitle;

  /// No description provided for @mfgBtnEditQuestionnaire.
  ///
  /// In pt, this message translates to:
  /// **'Editar questionário'**
  String get mfgBtnEditQuestionnaire;

  /// No description provided for @mfgCompanySectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Empresa'**
  String get mfgCompanySectionTitle;

  /// No description provided for @mfgFieldSupportEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail de suporte'**
  String get mfgFieldSupportEmail;

  /// No description provided for @mfgLabelCnpj.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ'**
  String get mfgLabelCnpj;

  /// No description provided for @mfgBtnSaveProfile.
  ///
  /// In pt, this message translates to:
  /// **'Guardar perfil'**
  String get mfgBtnSaveProfile;

  /// No description provided for @mfgCatalogSectionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo (homologações)'**
  String get mfgCatalogSectionTitle;

  /// No description provided for @mfgCatalogIntro.
  ///
  /// In pt, this message translates to:
  /// **'Equipamentos aqui ficam sem instituição — visíveis para montagem de treinos. Com versões derivadas, o registo original deixa de ser editável.'**
  String get mfgCatalogIntro;

  /// No description provided for @mfgNewVersionFromRecord.
  ///
  /// In pt, this message translates to:
  /// **'Nova versão a partir do registo #{id}'**
  String mfgNewVersionFromRecord(Object id);

  /// No description provided for @mfgFieldEquipmentName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do equipamento'**
  String get mfgFieldEquipmentName;

  /// No description provided for @mfgFieldModel.
  ///
  /// In pt, this message translates to:
  /// **'Modelo'**
  String get mfgFieldModel;

  /// No description provided for @mfgFieldSectorOptionalCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Setor (opcional)'**
  String get mfgFieldSectorOptionalCatalog;

  /// No description provided for @mfgCategoryOptionalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Categoria (opcional)'**
  String get mfgCategoryOptionalLabel;

  /// No description provided for @mfgBtnAddToCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar ao catálogo'**
  String get mfgBtnAddToCatalog;

  /// No description provided for @mfgFilterListLabel.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar lista'**
  String get mfgFilterListLabel;

  /// No description provided for @mfgEquipmentEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum equipamento ainda.'**
  String get mfgEquipmentEmpty;

  /// No description provided for @mfgEquipmentDerivedFrom.
  ///
  /// In pt, this message translates to:
  /// **'Versão derivada de #{parentId} · {model}'**
  String mfgEquipmentDerivedFrom(Object parentId, Object model);

  /// No description provided for @mfgBtnNewVersion.
  ///
  /// In pt, this message translates to:
  /// **'Nova versão'**
  String get mfgBtnNewVersion;

  /// No description provided for @mfgDashQuickCatalogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Equipamentos no catálogo'**
  String get mfgDashQuickCatalogTitle;

  /// No description provided for @mfgDashQuickCatalogBody.
  ///
  /// In pt, this message translates to:
  /// **'Registe modelo, documentação e pré-definições de treino num fluxo em dois passos.'**
  String get mfgDashQuickCatalogBody;

  /// No description provided for @mfgDashNewEquipment.
  ///
  /// In pt, this message translates to:
  /// **'Novo equipamento'**
  String get mfgDashNewEquipment;

  /// No description provided for @mfgEquipWizardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo equipamento'**
  String get mfgEquipWizardTitle;

  /// No description provided for @mfgEquipWizardEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar equipamento'**
  String get mfgEquipWizardEditTitle;

  /// No description provided for @mfgEquipWizardSaveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Guardar alterações'**
  String get mfgEquipWizardSaveChanges;

  /// No description provided for @mfgBtnEditEquipment.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get mfgBtnEditEquipment;

  /// No description provided for @mfgEquipWizardStep1.
  ///
  /// In pt, this message translates to:
  /// **'Identificação e ficha'**
  String get mfgEquipWizardStep1;

  /// No description provided for @mfgEquipWizardStep2.
  ///
  /// In pt, this message translates to:
  /// **'Treino e anexos'**
  String get mfgEquipWizardStep2;

  /// No description provided for @mfgEquipWizardNext.
  ///
  /// In pt, this message translates to:
  /// **'Seguinte'**
  String get mfgEquipWizardNext;

  /// No description provided for @mfgEquipWizardBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get mfgEquipWizardBack;

  /// No description provided for @mfgEquipWizardSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get mfgEquipWizardSubmit;

  /// No description provided for @mfgEquipErrInvalidInteger.
  ///
  /// In pt, this message translates to:
  /// **'Use números inteiros nos campos numéricos opcionais.'**
  String get mfgEquipErrInvalidInteger;

  /// No description provided for @mfgEquipErrHoursRange.
  ///
  /// In pt, this message translates to:
  /// **'Horas de treino: entre 1 e 999.'**
  String get mfgEquipErrHoursRange;

  /// No description provided for @mfgEquipErrPassRange.
  ///
  /// In pt, this message translates to:
  /// **'Nota mínima (%): entre 40 e 100.'**
  String get mfgEquipErrPassRange;

  /// No description provided for @mfgEquipErrCertMonthsRange.
  ///
  /// In pt, this message translates to:
  /// **'Validade do certificado (meses): entre 1 e 240.'**
  String get mfgEquipErrCertMonthsRange;

  /// No description provided for @mfgEquipErrReassessRange.
  ///
  /// In pt, this message translates to:
  /// **'Reavaliação (dias): entre 1 e 365.'**
  String get mfgEquipErrReassessRange;

  /// No description provided for @mfgEquipErrQuantityRange.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade: pelo menos 1 se preenchida.'**
  String get mfgEquipErrQuantityRange;

  /// No description provided for @mfgEquipFieldFirmware.
  ///
  /// In pt, this message translates to:
  /// **'Firmware (versão)'**
  String get mfgEquipFieldFirmware;

  /// No description provided for @mfgEquipFieldSerial.
  ///
  /// In pt, this message translates to:
  /// **'Número de série'**
  String get mfgEquipFieldSerial;

  /// No description provided for @mfgEquipCategoryRequired.
  ///
  /// In pt, this message translates to:
  /// **'Categoria *'**
  String get mfgEquipCategoryRequired;

  /// No description provided for @mfgEquipSnackCategoryRequired.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma categoria para o equipamento raiz.'**
  String get mfgEquipSnackCategoryRequired;

  /// No description provided for @mfgEquipSpecsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atributos técnicos (opcional)'**
  String get mfgEquipSpecsTitle;

  /// No description provided for @mfgEquipSpecLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get mfgEquipSpecLabel;

  /// No description provided for @mfgEquipSpecValue.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get mfgEquipSpecValue;

  /// No description provided for @mfgEquipAddSpecRow.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar linha'**
  String get mfgEquipAddSpecRow;

  /// No description provided for @mfgEquipFieldIntroVideoUrl.
  ///
  /// In pt, this message translates to:
  /// **'URL vídeo de introdução (opcional)'**
  String get mfgEquipFieldIntroVideoUrl;

  /// No description provided for @mfgEquipDefaultsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pré-definições de treino (opcional)'**
  String get mfgEquipDefaultsTitle;

  /// No description provided for @mfgEquipDefaultsRangeHint.
  ///
  /// In pt, this message translates to:
  /// **'Se preencher: horas 1–999, nota 40–100 %, certificado 1–240 meses, reavaliação 1–365 dias, quantidade ≥ 1.'**
  String get mfgEquipDefaultsRangeHint;

  /// No description provided for @mfgEquipHelperHours.
  ///
  /// In pt, this message translates to:
  /// **'Opcional · inteiro · 1–999'**
  String get mfgEquipHelperHours;

  /// No description provided for @mfgEquipHelperPass.
  ///
  /// In pt, this message translates to:
  /// **'Opcional · inteiro · 40–100'**
  String get mfgEquipHelperPass;

  /// No description provided for @mfgEquipHelperCertMonths.
  ///
  /// In pt, this message translates to:
  /// **'Opcional · inteiro · 1–240'**
  String get mfgEquipHelperCertMonths;

  /// No description provided for @mfgEquipHelperReassess.
  ///
  /// In pt, this message translates to:
  /// **'Opcional · inteiro · 1–365'**
  String get mfgEquipHelperReassess;

  /// No description provided for @mfgEquipHelperQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Opcional · inteiro · ≥ 1'**
  String get mfgEquipHelperQuantity;

  /// No description provided for @mfgEquipDefaultTrainingHours.
  ///
  /// In pt, this message translates to:
  /// **'Horas de treino'**
  String get mfgEquipDefaultTrainingHours;

  /// No description provided for @mfgEquipDefaultPassingScore.
  ///
  /// In pt, this message translates to:
  /// **'Nota mínima (%)'**
  String get mfgEquipDefaultPassingScore;

  /// No description provided for @mfgEquipDefaultCertMonths.
  ///
  /// In pt, this message translates to:
  /// **'Validade certificado (meses)'**
  String get mfgEquipDefaultCertMonths;

  /// No description provided for @mfgEquipDefaultReassessmentDays.
  ///
  /// In pt, this message translates to:
  /// **'Reavaliação (dias)'**
  String get mfgEquipDefaultReassessmentDays;

  /// No description provided for @mfgEquipFieldQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get mfgEquipFieldQuantity;

  /// No description provided for @mfgEquipFieldStatus.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get mfgEquipFieldStatus;

  /// No description provided for @mfgEquipStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get mfgEquipStatusActive;

  /// No description provided for @mfgEquipStatusInactive.
  ///
  /// In pt, this message translates to:
  /// **'Inativo'**
  String get mfgEquipStatusInactive;

  /// No description provided for @mfgEquipAttachmentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ficheiros (opcional)'**
  String get mfgEquipAttachmentsTitle;

  /// No description provided for @mfgEquipAttachImage.
  ///
  /// In pt, this message translates to:
  /// **'Imagem do equipamento'**
  String get mfgEquipAttachImage;

  /// No description provided for @mfgEquipAttachManualOp.
  ///
  /// In pt, this message translates to:
  /// **'Manual do operador (PDF)'**
  String get mfgEquipAttachManualOp;

  /// No description provided for @mfgEquipAttachManualMaint.
  ///
  /// In pt, this message translates to:
  /// **'Manual de manutenção (PDF)'**
  String get mfgEquipAttachManualMaint;

  /// No description provided for @mfgEquipAttachDatasheet.
  ///
  /// In pt, this message translates to:
  /// **'Ficha técnica (PDF)'**
  String get mfgEquipAttachDatasheet;

  /// No description provided for @mfgEquipAttachIntroVideo.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo de introdução (MP4)'**
  String get mfgEquipAttachIntroVideo;

  /// No description provided for @mfgEquipPickFile.
  ///
  /// In pt, this message translates to:
  /// **'Escolher'**
  String get mfgEquipPickFile;

  /// No description provided for @mfgEquipClearFile.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get mfgEquipClearFile;

  /// No description provided for @mfgEquipSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar nome, modelo ou série'**
  String get mfgEquipSearchHint;

  /// No description provided for @mfgEquipFilterStatusLabel.
  ///
  /// In pt, this message translates to:
  /// **'Estado na lista'**
  String get mfgEquipFilterStatusLabel;

  /// No description provided for @mfgEquipStatusFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get mfgEquipStatusFilterAll;

  /// No description provided for @mfgEquipTemplatesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} template(s) oficial(is)'**
  String mfgEquipTemplatesCount(Object count);

  /// No description provided for @mfgEquipSortLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar lista'**
  String get mfgEquipSortLabel;

  /// No description provided for @mfgEquipSortName.
  ///
  /// In pt, this message translates to:
  /// **'Nome (A–Z)'**
  String get mfgEquipSortName;

  /// No description provided for @mfgEquipSortUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Actualizados recentemente'**
  String get mfgEquipSortUpdated;

  /// No description provided for @mfgEquipSortTemplates.
  ///
  /// In pt, this message translates to:
  /// **'Mais templates oficiais'**
  String get mfgEquipSortTemplates;

  /// No description provided for @mfgEquipListResultCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} modelo(s) listado(s) (até 200).'**
  String mfgEquipListResultCount(Object count);

  /// No description provided for @mfgEquipClearFilters.
  ///
  /// In pt, this message translates to:
  /// **'Limpar filtros'**
  String get mfgEquipClearFilters;

  /// No description provided for @mfgEquipSnackPartialUpload.
  ///
  /// In pt, this message translates to:
  /// **'Equipamento criado; alguns anexos falharam.'**
  String get mfgEquipSnackPartialUpload;

  /// No description provided for @mfgValidationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Credenciação do fabricante'**
  String get mfgValidationTitle;

  /// No description provided for @mfgValidationStateLine.
  ///
  /// In pt, this message translates to:
  /// **'Estado: {status}'**
  String mfgValidationStateLine(Object status);

  /// No description provided for @mfgFlowStepCompany.
  ///
  /// In pt, this message translates to:
  /// **'Dados da empresa'**
  String get mfgFlowStepCompany;

  /// No description provided for @mfgFlowStepFluxxoReview.
  ///
  /// In pt, this message translates to:
  /// **'Análise da plataforma'**
  String get mfgFlowStepFluxxoReview;

  /// No description provided for @mfgFlowStepHomologation.
  ///
  /// In pt, this message translates to:
  /// **'Homologação'**
  String get mfgFlowStepHomologation;

  /// No description provided for @mfgValStatusPendingInfo.
  ///
  /// In pt, this message translates to:
  /// **'Informações pendentes'**
  String get mfgValStatusPendingInfo;

  /// No description provided for @mfgValStatusPendingValidation.
  ///
  /// In pt, this message translates to:
  /// **'Em análise pela equipa'**
  String get mfgValStatusPendingValidation;

  /// No description provided for @mfgValStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo na rede credenciada'**
  String get mfgValStatusActive;

  /// No description provided for @mfgValStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Validação recusada'**
  String get mfgValStatusRejected;

  /// No description provided for @mfgValHelpPendingInfo.
  ///
  /// In pt, this message translates to:
  /// **'Complete os dados da empresa e submeta para validação. Pode anexar documentação de suporte em «Operações» → Documentos.'**
  String get mfgValHelpPendingInfo;

  /// No description provided for @mfgValHelpPendingValidation.
  ///
  /// In pt, this message translates to:
  /// **'O seu pedido está na fila de análise Fluxxo. Prazo estimado: 24 a 48 horas úteis. Receberá um e-mail quando for aprovado.'**
  String get mfgValHelpPendingValidation;

  /// No description provided for @mfgValHelpActive.
  ///
  /// In pt, this message translates to:
  /// **'O fabricante está homologado na rede. Instrutores podem solicitar credenciação a este fabricante e usar os templates oficiais no catálogo.'**
  String get mfgValHelpActive;

  /// No description provided for @mfgValHelpRejected.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste os dados ou documentação indicados pela equipa e volte a submeter.'**
  String get mfgValHelpRejected;

  /// No description provided for @mfgValHelpDefault.
  ///
  /// In pt, this message translates to:
  /// **'Estado de credenciação do fabricante na plataforma.'**
  String get mfgValHelpDefault;

  /// No description provided for @mfgBtnSubmitForReview.
  ///
  /// In pt, this message translates to:
  /// **'Submeter para análise'**
  String get mfgBtnSubmitForReview;

  /// No description provided for @mfgBtnResubmitForReview.
  ///
  /// In pt, this message translates to:
  /// **'Voltar a submeter para análise'**
  String get mfgBtnResubmitForReview;

  /// No description provided for @trnSnackSectorRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o setor.'**
  String get trnSnackSectorRequired;

  /// No description provided for @trnSnackCodeRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe o código.'**
  String get trnSnackCodeRequired;

  /// No description provided for @trnSnackSessionPaused.
  ///
  /// In pt, this message translates to:
  /// **'A sessão está em pausa. Aguarde o instrutor retomar.'**
  String get trnSnackSessionPaused;

  /// No description provided for @trnSnackPickOption.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma opção.'**
  String get trnSnackPickOption;

  /// No description provided for @trnSnackLgpdCheckbox.
  ///
  /// In pt, this message translates to:
  /// **'Marque a caixa para confirmar que leu e concorda.'**
  String get trnSnackLgpdCheckbox;

  /// No description provided for @trnSnackJsonCopied.
  ///
  /// In pt, this message translates to:
  /// **'Dados copiados para a área de transferência (JSON).'**
  String get trnSnackJsonCopied;

  /// No description provided for @trnSnackCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelado.'**
  String get trnSnackCancelled;

  /// No description provided for @trnSnackFormOpenFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o formulário.'**
  String get trnSnackFormOpenFailed;

  /// No description provided for @trnSnackFollowUpAvailableFrom.
  ///
  /// In pt, this message translates to:
  /// **'Disponível a partir de {due}.'**
  String trnSnackFollowUpAvailableFrom(Object due);

  /// No description provided for @trnSnackFollowUpNotYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não pode responder.'**
  String get trnSnackFollowUpNotYet;

  /// No description provided for @trnSnackResponsesSaved.
  ///
  /// In pt, this message translates to:
  /// **'Respostas registadas.'**
  String get trnSnackResponsesSaved;

  /// No description provided for @trnSnackCertPdfDownloaded.
  ///
  /// In pt, this message translates to:
  /// **'PDF do certificado descarregado.'**
  String get trnSnackCertPdfDownloaded;

  /// No description provided for @trnSnackCertPdfFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível descarregar o PDF.'**
  String get trnSnackCertPdfFailed;

  /// No description provided for @trnSnackPickInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a instituição no pré-registro.'**
  String get trnSnackPickInstitution;

  /// No description provided for @trnSnackPickReason.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o motivo do pedido.'**
  String get trnSnackPickReason;

  /// No description provided for @trnSnackRequestSent.
  ///
  /// In pt, this message translates to:
  /// **'Pedido enviado à instituição.'**
  String get trnSnackRequestSent;

  /// No description provided for @trnDeleteAccountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get trnDeleteAccountTitle;

  /// No description provided for @trnDeleteAccountBodyGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação anonimiza a sua conta de forma irreversível (Art. 18 LGPD). Confirme com EXCLUIR e autentique novamente com Google.'**
  String get trnDeleteAccountBodyGoogle;

  /// No description provided for @trnDeleteAccountBodyPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação anonimiza a sua conta de forma irreversível (Art. 18 LGPD). Digite EXCLUIR em maiúsculas e a sua senha.'**
  String get trnDeleteAccountBodyPassword;

  /// No description provided for @trnFieldPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get trnFieldPassword;

  /// No description provided for @trnFieldConfirmDelete.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar (digite EXCLUIR)'**
  String get trnFieldConfirmDelete;

  /// No description provided for @trnBtnConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get trnBtnConfirm;

  /// No description provided for @trnApiOk.
  ///
  /// In pt, this message translates to:
  /// **'API ok'**
  String get trnApiOk;

  /// No description provided for @trnApiOffline.
  ///
  /// In pt, this message translates to:
  /// **'Sem API'**
  String get trnApiOffline;

  /// No description provided for @trnTooltipPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get trnTooltipPrivacy;

  /// No description provided for @trnMenuExportJson.
  ///
  /// In pt, this message translates to:
  /// **'Exportar meus dados (JSON)'**
  String get trnMenuExportJson;

  /// No description provided for @trnMenuDeleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir minha conta'**
  String get trnMenuDeleteAccount;

  /// No description provided for @trnTooltipSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get trnTooltipSignOut;

  /// No description provided for @trnPrivacyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e dados'**
  String get trnPrivacyTitle;

  /// No description provided for @trnLgpdIntro.
  ///
  /// In pt, this message translates to:
  /// **'Antes de usar o treinamento, precisamos do seu consentimento explícito (LGPD — Lei 13.709/2018):'**
  String get trnLgpdIntro;

  /// No description provided for @trnLgpdBullets.
  ///
  /// In pt, this message translates to:
  /// **'• Finalidade: identificação em treinamentos, certificados e relatórios agregados da instituição.\n• Compartilhamento: dados individuais apenas com o instrutor durante a sessão; à instituição, de forma agregada.\n• Retenção: até 5 anos após o último treinamento para auditoria, salvo exclusão ou anonimização a seu pedido.\n• Direitos: acesso, correção, portabilidade e exclusão pelo menu Privacidade (ícone no topo).\n• Google: ao usar login Google, dados também são tratados segundo a política do Google.'**
  String get trnLgpdBullets;

  /// No description provided for @trnLgpdCheckboxTitle.
  ///
  /// In pt, this message translates to:
  /// **'Li e concordo com o tratamento dos meus dados pessoais conforme a Política de Privacidade do App²cation.'**
  String get trnLgpdCheckboxTitle;

  /// No description provided for @trnLgpdAfterConsentHint.
  ///
  /// In pt, this message translates to:
  /// **'Depois de continuar, pode exportar os seus dados ou pedir exclusão da conta a qualquer momento no menu Privacidade (ícone de escudo) no cabeçalho.'**
  String get trnLgpdAfterConsentHint;

  /// No description provided for @trnBtnContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get trnBtnContinue;

  /// No description provided for @trnPreregTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pré-registro'**
  String get trnPreregTitle;

  /// No description provided for @trnPreregSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Dados reais gravados na sua conta.'**
  String get trnPreregSubtitle;

  /// No description provided for @trnFieldInstitutionOptional.
  ///
  /// In pt, this message translates to:
  /// **'Instituição (opcional)'**
  String get trnFieldInstitutionOptional;

  /// No description provided for @trnInstitutionNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem instituição'**
  String get trnInstitutionNone;

  /// No description provided for @trnProfileInstitutionHint.
  ///
  /// In pt, this message translates to:
  /// **'Vincular um hospital desbloqueia o parque de equipamentos da instituição para pedidos de treino e pode ser exigido pela política da sua unidade.'**
  String get trnProfileInstitutionHint;

  /// No description provided for @trnFieldSectorTeam.
  ///
  /// In pt, this message translates to:
  /// **'Setor / equipe *'**
  String get trnFieldSectorTeam;

  /// No description provided for @trnFieldEquipmentContext.
  ///
  /// In pt, this message translates to:
  /// **'Equipamento / contexto'**
  String get trnFieldEquipmentContext;

  /// No description provided for @trnFieldSessionAtOptional.
  ///
  /// In pt, this message translates to:
  /// **'Data e hora da sessão (opcional)'**
  String get trnFieldSessionAtOptional;

  /// No description provided for @trnHintDatetime.
  ///
  /// In pt, this message translates to:
  /// **'AAAA-MM-DD HH:MM'**
  String get trnHintDatetime;

  /// No description provided for @trnBtnSaveContinue.
  ///
  /// In pt, this message translates to:
  /// **'Salvar e continuar'**
  String get trnBtnSaveContinue;

  /// No description provided for @trnCertificatesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Certificados'**
  String get trnCertificatesTitle;

  /// No description provided for @trnCertificatesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum certificado ainda — conclua um treinamento com nota ≥ mínima.'**
  String get trnCertificatesEmpty;

  /// No description provided for @trnCertScoreValid.
  ///
  /// In pt, this message translates to:
  /// **'Nota {score} · válido até {expires}'**
  String trnCertScoreValid(Object score, Object expires);

  /// No description provided for @trnFollowUpsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reavaliações pós-treino'**
  String get trnFollowUpsTitle;

  /// No description provided for @trnFollowUpsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Questionários curtos (ex.: 10, 15 e 30 dias após a conclusão), conforme configuração do treino.'**
  String get trnFollowUpsIntro;

  /// No description provided for @trnFollowUpsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma reavaliação agendada.'**
  String get trnFollowUpsEmpty;

  /// No description provided for @trnFollowUpListSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Dia +{days} · {status} · previsto {due}'**
  String trnFollowUpListSubtitle(Object days, Object status, Object due);

  /// No description provided for @trnTrainingRequestTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedido de treinamento (instituição)'**
  String get trnTrainingRequestTitle;

  /// No description provided for @trnTrainingRequestIntro.
  ///
  /// In pt, this message translates to:
  /// **'Motivo padronizado, prioridade e datas preferidas para o pedido.'**
  String get trnTrainingRequestIntro;

  /// No description provided for @trnLoadingOptions.
  ///
  /// In pt, this message translates to:
  /// **'A carregar opções…'**
  String get trnLoadingOptions;

  /// No description provided for @trnFieldReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo'**
  String get trnFieldReason;

  /// No description provided for @trnFieldPriority.
  ///
  /// In pt, this message translates to:
  /// **'Prioridade'**
  String get trnFieldPriority;

  /// No description provided for @trnFieldParkUnitOptional.
  ///
  /// In pt, this message translates to:
  /// **'Unidade do parque (opcional)'**
  String get trnFieldParkUnitOptional;

  /// No description provided for @trnParkUnitHelper.
  ///
  /// In pt, this message translates to:
  /// **'Lista da instituição do seu pré-registro.'**
  String get trnParkUnitHelper;

  /// No description provided for @trnParkEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Sem unidades no parque ou complete o pré-registro com instituição para carregar o parque.'**
  String get trnParkEmptyHint;

  /// No description provided for @trnFieldPreferredDate.
  ///
  /// In pt, this message translates to:
  /// **'Data preferida (opcional)'**
  String get trnFieldPreferredDate;

  /// No description provided for @trnHintDate.
  ///
  /// In pt, this message translates to:
  /// **'AAAA-MM-DD'**
  String get trnHintDate;

  /// No description provided for @trnFieldLatestAcceptable.
  ///
  /// In pt, this message translates to:
  /// **'Última data aceitável (opcional)'**
  String get trnFieldLatestAcceptable;

  /// No description provided for @trnFieldNotesOptional.
  ///
  /// In pt, this message translates to:
  /// **'Notas (opcional)'**
  String get trnFieldNotesOptional;

  /// No description provided for @trnNotesHint.
  ///
  /// In pt, this message translates to:
  /// **'Detalhe local, turno, contacto…'**
  String get trnNotesHint;

  /// No description provided for @trnBtnSendRequest.
  ///
  /// In pt, this message translates to:
  /// **'Enviar pedido'**
  String get trnBtnSendRequest;

  /// No description provided for @trnMyRequests.
  ///
  /// In pt, this message translates to:
  /// **'Meus pedidos'**
  String get trnMyRequests;

  /// No description provided for @trnJoinTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar no treinamento'**
  String get trnJoinTitle;

  /// No description provided for @trnJoinIntro.
  ///
  /// In pt, this message translates to:
  /// **'Use o código fornecido pelo instrutor.'**
  String get trnJoinIntro;

  /// No description provided for @trnJoinIntroDetail.
  ///
  /// In pt, this message translates to:
  /// **'O instrutor partilha o código ou hash depois de ser convidado (e-mail, aplicação ou presencial). Pode colar a partir de uma mensagem; espaços são ignorados e maiúsculas/minúsculas não importam.'**
  String get trnJoinIntroDetail;

  /// No description provided for @trnJoinAccessCodeHint.
  ///
  /// In pt, this message translates to:
  /// **'Cole o código enviado pelo instrutor'**
  String get trnJoinAccessCodeHint;

  /// No description provided for @trnJoinHashKeepTyping.
  ///
  /// In pt, this message translates to:
  /// **'A maioria dos códigos tem 12 caracteres — continue a escrever ou cole o código completo.'**
  String get trnJoinHashKeepTyping;

  /// No description provided for @trnJoinHashFormatOk.
  ///
  /// In pt, this message translates to:
  /// **'O formato parece válido. Toque em confirmar para entrar.'**
  String get trnJoinHashFormatOk;

  /// No description provided for @trnFieldAccessCode.
  ///
  /// In pt, this message translates to:
  /// **'Código de acesso'**
  String get trnFieldAccessCode;

  /// No description provided for @trnBtnConfirmJoin.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar entrada'**
  String get trnBtnConfirmJoin;

  /// No description provided for @trnJoinOfflineHint.
  ///
  /// In pt, this message translates to:
  /// **'A aplicação não consegue contactar o servidor. Verifique a ligação antes de confirmar a entrada.'**
  String get trnJoinOfflineHint;

  /// No description provided for @trnWaitingRoomTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sala de espera'**
  String get trnWaitingRoomTitle;

  /// No description provided for @trnWaitingRoomBody.
  ///
  /// In pt, this message translates to:
  /// **'Assim que o instrutor iniciar, o questionário abre automaticamente.'**
  String get trnWaitingRoomBody;

  /// No description provided for @trnWaitingHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando início do treinamento'**
  String get trnWaitingHeroTitle;

  /// No description provided for @trnWaitingHeroBody.
  ///
  /// In pt, this message translates to:
  /// **'O instrutor iniciará a sessão em breve. Mantenha esta janela aberta para entrar automaticamente na sala virtual.'**
  String get trnWaitingHeroBody;

  /// No description provided for @trnWaitingOfflineHint.
  ///
  /// In pt, this message translates to:
  /// **'Não há ligação à API. Quando a rede voltar, puxe para actualizar ou toque em «Actualizar estado» para sincronizar assim que o instrutor iniciar.'**
  String get trnWaitingOfflineHint;

  /// No description provided for @trnWaitingStatusChip.
  ///
  /// In pt, this message translates to:
  /// **'Status: sala de espera ativa'**
  String get trnWaitingStatusChip;

  /// No description provided for @trnWaitingTestConnection.
  ///
  /// In pt, this message translates to:
  /// **'Testar conexão e periféricos'**
  String get trnWaitingTestConnection;

  /// No description provided for @trnWaitingCheckNow.
  ///
  /// In pt, this message translates to:
  /// **'Actualizar estado'**
  String get trnWaitingCheckNow;

  /// No description provided for @trnWaitingPingOk.
  ///
  /// In pt, this message translates to:
  /// **'Ligação ao servidor OK.'**
  String get trnWaitingPingOk;

  /// No description provided for @trnWaitingPingFail.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível contactar o servidor.'**
  String get trnWaitingPingFail;

  /// No description provided for @trnWaitingPrivacyNote.
  ///
  /// In pt, this message translates to:
  /// **'Câmara e microfone permanecem desativados por defeito nesta versão.'**
  String get trnWaitingPrivacyNote;

  /// No description provided for @trnHeaderProfileStep.
  ///
  /// In pt, this message translates to:
  /// **'Perfil e instituição'**
  String get trnHeaderProfileStep;

  /// No description provided for @trnHeaderWaitingInstructor.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando instrutor'**
  String get trnHeaderWaitingInstructor;

  /// No description provided for @trnHeaderRealtimeActive.
  ///
  /// In pt, this message translates to:
  /// **'Tempo real: ativo'**
  String get trnHeaderRealtimeActive;

  /// No description provided for @trnQuestionSidebarNavTitle.
  ///
  /// In pt, this message translates to:
  /// **'Navegação'**
  String get trnQuestionSidebarNavTitle;

  /// No description provided for @trnEmptyRecoverySync.
  ///
  /// In pt, this message translates to:
  /// **'A sincronizar repescagem ou a concluir o treino…'**
  String get trnEmptyRecoverySync;

  /// No description provided for @trnEmptyNoQuestions.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma questão disponível.'**
  String get trnEmptyNoQuestions;

  /// No description provided for @trnPausedSessionBanner.
  ///
  /// In pt, this message translates to:
  /// **'Sessão em pausa. Não é possível responder até o instrutor retomar.'**
  String get trnPausedSessionBanner;

  /// No description provided for @trnRecoveryBanner.
  ///
  /// In pt, this message translates to:
  /// **'Repescagem: apenas as questões que o instrutor libertou para nova tentativa.'**
  String get trnRecoveryBanner;

  /// No description provided for @trnProgressLabel.
  ///
  /// In pt, this message translates to:
  /// **'PROGRESSO'**
  String get trnProgressLabel;

  /// No description provided for @trnQuestionProgress.
  ///
  /// In pt, this message translates to:
  /// **'Questão {current} de {total}'**
  String trnQuestionProgress(Object current, Object total);

  /// No description provided for @trnBtnConfirmAnswer.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar resposta'**
  String get trnBtnConfirmAnswer;

  /// No description provided for @trnBtnContinueAfterFeedback.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get trnBtnContinueAfterFeedback;

  /// No description provided for @trnAnswerFeedbackCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Resposta correta.'**
  String get trnAnswerFeedbackCorrect;

  /// No description provided for @trnAnswerFeedbackIncorrect.
  ///
  /// In pt, this message translates to:
  /// **'Resposta incorreta.'**
  String get trnAnswerFeedbackIncorrect;

  /// No description provided for @trnAnswerCorrectWas.
  ///
  /// In pt, this message translates to:
  /// **'Resposta certa: {label}'**
  String trnAnswerCorrectWas(Object label);

  /// No description provided for @trnBtnSubmitResponses.
  ///
  /// In pt, this message translates to:
  /// **'Enviar respostas'**
  String get trnBtnSubmitResponses;

  /// No description provided for @trnOptionalHint.
  ///
  /// In pt, this message translates to:
  /// **'Opcional'**
  String get trnOptionalHint;

  /// No description provided for @trnResultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Treinamento concluído'**
  String get trnResultTitle;

  /// No description provided for @trnScoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nota (0–10)'**
  String get trnScoreLabel;

  /// No description provided for @trnResultApprovedBanner.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado — nota igual ou superior a 7,0.'**
  String get trnResultApprovedBanner;

  /// No description provided for @trnResultInsufficientBanner.
  ///
  /// In pt, this message translates to:
  /// **'Nota abaixo de 7,0. Em caso de dúvida, fale com o instrutor.'**
  String get trnResultInsufficientBanner;

  /// No description provided for @trnResultRecoveryNote.
  ///
  /// In pt, this message translates to:
  /// **'Está em recuperação: conclua as questões indicadas pelo instrutor.'**
  String get trnResultRecoveryNote;

  /// No description provided for @trnResultInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Instituição: {name}'**
  String trnResultInstitution(Object name);

  /// No description provided for @trnResultRefresh.
  ///
  /// In pt, this message translates to:
  /// **'Actualizar estado'**
  String get trnResultRefresh;

  /// No description provided for @trnResultCertificateHint.
  ///
  /// In pt, this message translates to:
  /// **'Se o instrutor acabou de encerrar o treino, actualize — o certificado pode demorar alguns segundos a aparecer.'**
  String get trnResultCertificateHint;

  /// No description provided for @trnResultCertificateDownload.
  ///
  /// In pt, this message translates to:
  /// **'Certificado (PDF)'**
  String get trnResultCertificateDownload;

  /// No description provided for @trnResultFollowUpIntro.
  ///
  /// In pt, this message translates to:
  /// **'Quando a data prevista abrir, toque em Responder para preencher o breve questionário.'**
  String get trnResultFollowUpIntro;

  /// No description provided for @trnResultOfflineHint.
  ///
  /// In pt, this message translates to:
  /// **'Sem ligação ao servidor. Pode actualizar quando a rede voltar; o certificado (PDF) e o questionário de seguimento só funcionam online.'**
  String get trnResultOfflineHint;

  /// No description provided for @trnBtnJoinAnother.
  ///
  /// In pt, this message translates to:
  /// **'Entrar em outro treinamento'**
  String get trnBtnJoinAnother;

  /// No description provided for @trnFollowUpDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reavaliação pós-treino'**
  String get trnFollowUpDialogTitle;

  /// No description provided for @trnTrainingDefaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Treinamento'**
  String get trnTrainingDefaultTitle;

  /// No description provided for @trnRequestListPark.
  ///
  /// In pt, this message translates to:
  /// **'Parque: {detail}'**
  String trnRequestListPark(Object detail);

  /// No description provided for @trnRequestListPref.
  ///
  /// In pt, this message translates to:
  /// **'pref. {date}'**
  String trnRequestListPref(Object date);

  /// No description provided for @trnRequestListLimit.
  ///
  /// In pt, this message translates to:
  /// **'limite {date}'**
  String trnRequestListLimit(Object date);

  /// No description provided for @trnFollowUpRespond.
  ///
  /// In pt, this message translates to:
  /// **'Responder'**
  String get trnFollowUpRespond;

  /// No description provided for @trnTooltipCertPdf.
  ///
  /// In pt, this message translates to:
  /// **'Descarregar PDF'**
  String get trnTooltipCertPdf;

  /// No description provided for @mfgTplIntro.
  ///
  /// In pt, this message translates to:
  /// **'Blocos e perguntas seguem o mesmo formato dos treinos operacionais. Os instrutores homologados clonam este conteúdo.'**
  String get mfgTplIntro;

  /// No description provided for @mfgTplSectionQuestions.
  ///
  /// In pt, this message translates to:
  /// **'Perguntas'**
  String get mfgTplSectionQuestions;

  /// No description provided for @mfgTplBtnAddQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta'**
  String get mfgTplBtnAddQuestion;

  /// No description provided for @mfgTplSnackSaved.
  ///
  /// In pt, this message translates to:
  /// **'Questionário guardado.'**
  String get mfgTplSnackSaved;

  /// No description provided for @mfgTplErrNeedCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Cada pergunta precisa de uma opção correta.'**
  String get mfgTplErrNeedCorrect;

  /// No description provided for @mfgTplErrMinQuestions.
  ///
  /// In pt, this message translates to:
  /// **'Adicione pelo menos uma pergunta com 2+ opções.'**
  String get mfgTplErrMinQuestions;

  /// No description provided for @mfgTplErrQuestionNeedTwoOptions.
  ///
  /// In pt, this message translates to:
  /// **'Cada pergunta com enunciado precisa de pelo menos duas opções preenchidas.'**
  String get mfgTplErrQuestionNeedTwoOptions;

  /// No description provided for @mfgTplErrCorrectMustHaveLabel.
  ///
  /// In pt, this message translates to:
  /// **'A opção marcada como correta tem de ter texto.'**
  String get mfgTplErrCorrectMustHaveLabel;

  /// No description provided for @mfgTplBtnAddOption.
  ///
  /// In pt, this message translates to:
  /// **'Opção'**
  String get mfgTplBtnAddOption;

  /// No description provided for @mfgTplRemoveOptionTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Remover opção'**
  String get mfgTplRemoveOptionTooltip;

  /// No description provided for @mfgTplMaxOptionsSnack.
  ///
  /// In pt, this message translates to:
  /// **'No máximo 12 opções por pergunta.'**
  String get mfgTplMaxOptionsSnack;

  /// No description provided for @mfgTplOptionsCountHint.
  ///
  /// In pt, this message translates to:
  /// **'2–12 opções; linhas vazias são ignoradas ao guardar.'**
  String get mfgTplOptionsCountHint;

  /// No description provided for @mfgTplQuestionNumber.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta {n}'**
  String mfgTplQuestionNumber(Object n);

  /// No description provided for @mfgTplFieldPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Enunciado'**
  String get mfgTplFieldPrompt;

  /// No description provided for @mfgTplOptionsHint.
  ///
  /// In pt, this message translates to:
  /// **'Opções (marque a correta)'**
  String get mfgTplOptionsHint;

  /// No description provided for @mfgTplOptionNumber.
  ///
  /// In pt, this message translates to:
  /// **'Opção {n}'**
  String mfgTplOptionNumber(Object n);

  /// No description provided for @mfgTplBtnSaveApi.
  ///
  /// In pt, this message translates to:
  /// **'Guardar questionário na API'**
  String get mfgTplBtnSaveApi;

  /// No description provided for @mfgTplOfficialBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo oficial'**
  String get mfgTplOfficialBlockTitle;

  /// No description provided for @mfgTplReloadTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar do servidor'**
  String get mfgTplReloadTooltip;

  /// No description provided for @mfgTplRefreshHint.
  ///
  /// In pt, this message translates to:
  /// **'Puxe para baixo para recarregar do servidor. Alterações não guardadas no formulário serão substituídas.'**
  String get mfgTplRefreshHint;

  /// No description provided for @mfgTplMoveUpTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Subir pergunta'**
  String get mfgTplMoveUpTooltip;

  /// No description provided for @mfgTplMoveDownTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Descer pergunta'**
  String get mfgTplMoveDownTooltip;

  /// No description provided for @mfgTplDiscardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Descartar alterações?'**
  String get mfgTplDiscardTitle;

  /// No description provided for @mfgTplDiscardBody.
  ///
  /// In pt, this message translates to:
  /// **'Tem edições não guardadas. Sair sem guardar?'**
  String get mfgTplDiscardBody;

  /// No description provided for @mfgTplKeepEditing.
  ///
  /// In pt, this message translates to:
  /// **'Continuar a editar'**
  String get mfgTplKeepEditing;

  /// No description provided for @mfgTplDiscardLeave.
  ///
  /// In pt, this message translates to:
  /// **'Sair sem guardar'**
  String get mfgTplDiscardLeave;

  /// No description provided for @mfgTplSectionBlocks.
  ///
  /// In pt, this message translates to:
  /// **'Secções do questionário'**
  String get mfgTplSectionBlocks;

  /// No description provided for @mfgTplFieldBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Título da secção'**
  String get mfgTplFieldBlockTitle;

  /// No description provided for @mfgTplBtnAddBlock.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar secção'**
  String get mfgTplBtnAddBlock;

  /// No description provided for @mfgTplRemoveBlockTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Remover secção e unir perguntas à secção acima'**
  String get mfgTplRemoveBlockTooltip;

  /// No description provided for @mfgTplBlockDefaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Secção {n}'**
  String mfgTplBlockDefaultTitle(int n);

  /// No description provided for @mfgTplViewEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get mfgTplViewEdit;

  /// No description provided for @mfgTplViewPreview.
  ///
  /// In pt, this message translates to:
  /// **'Pré-visualizar'**
  String get mfgTplViewPreview;

  /// No description provided for @mfgTplPreviewBanner.
  ///
  /// In pt, this message translates to:
  /// **'Pré-visualização ao estilo treinando: sem respostas gravadas e sem destacar a opção correcta.'**
  String get mfgTplPreviewBanner;

  /// No description provided for @mfgTplPreviewEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma pergunta com enunciado para mostrar. Volte a Editar e preencha pelo menos um enunciado.'**
  String get mfgTplPreviewEmpty;

  /// No description provided for @mfgTplMoveBlockUpTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Subir secção'**
  String get mfgTplMoveBlockUpTooltip;

  /// No description provided for @mfgTplMoveBlockDownTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Descer secção'**
  String get mfgTplMoveBlockDownTooltip;

  /// No description provided for @fluxPanelTraineeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo do treinando'**
  String get fluxPanelTraineeTitle;

  /// No description provided for @fluxPanelTraineeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Jornada alinhada à especificação: pré-registro → ingresso → LGPD → sessão em tempo real → resultado.'**
  String get fluxPanelTraineeSubtitle;

  /// No description provided for @fluxPanelTraineeS1Label.
  ///
  /// In pt, this message translates to:
  /// **'Perfil e contexto clínico'**
  String get fluxPanelTraineeS1Label;

  /// No description provided for @fluxPanelTraineeS1Detail.
  ///
  /// In pt, this message translates to:
  /// **'Setor, equipamento e instituição quando aplicável.'**
  String get fluxPanelTraineeS1Detail;

  /// No description provided for @fluxPanelTraineeS2Label.
  ///
  /// In pt, this message translates to:
  /// **'Ingresso na sessão'**
  String get fluxPanelTraineeS2Label;

  /// No description provided for @fluxPanelTraineeS2Detail.
  ///
  /// In pt, this message translates to:
  /// **'Código/hash fornecido pelo instrutor ou instituição.'**
  String get fluxPanelTraineeS2Detail;

  /// No description provided for @fluxPanelTraineeS3Label.
  ///
  /// In pt, this message translates to:
  /// **'Consentimento LGPD'**
  String get fluxPanelTraineeS3Label;

  /// No description provided for @fluxPanelTraineeS3Detail.
  ///
  /// In pt, this message translates to:
  /// **'Obrigatório antes de responder ao questionário.'**
  String get fluxPanelTraineeS3Detail;

  /// No description provided for @fluxPanelTraineeS4Label.
  ///
  /// In pt, this message translates to:
  /// **'Sala de espera e sessão ao vivo'**
  String get fluxPanelTraineeS4Label;

  /// No description provided for @fluxPanelTraineeS4Detail.
  ///
  /// In pt, this message translates to:
  /// **'Aguarda o instrutor iniciar; blocos libertados em sequência.'**
  String get fluxPanelTraineeS4Detail;

  /// No description provided for @fluxPanelTraineeS5Label.
  ///
  /// In pt, this message translates to:
  /// **'Respostas e resultado'**
  String get fluxPanelTraineeS5Label;

  /// No description provided for @fluxPanelTraineeS5Detail.
  ///
  /// In pt, this message translates to:
  /// **'Correção imediata; aprovação conforme regra do treino (ex.: ≥70%).'**
  String get fluxPanelTraineeS5Detail;

  /// No description provided for @fluxPanelInstructorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo do Application (instrutor)'**
  String get fluxPanelInstructorTitle;

  /// No description provided for @fluxPanelInstructorSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Credenciamento duplo (instituição + fabricante quando aplicável), criação de sessão e comando em tempo real.'**
  String get fluxPanelInstructorSubtitle;

  /// No description provided for @fluxPanelInstructorS1Label.
  ///
  /// In pt, this message translates to:
  /// **'Credenciamento'**
  String get fluxPanelInstructorS1Label;

  /// No description provided for @fluxPanelInstructorS1Detail.
  ///
  /// In pt, this message translates to:
  /// **'Instituição e catálogo no separador Credenciamento.'**
  String get fluxPanelInstructorS1Detail;

  /// No description provided for @fluxPanelInstructorS2Label.
  ///
  /// In pt, this message translates to:
  /// **'Criar treinamento e questionário'**
  String get fluxPanelInstructorS2Label;

  /// No description provided for @fluxPanelInstructorS2Detail.
  ///
  /// In pt, this message translates to:
  /// **'Treinos, blocos e perguntas alinhados ao equipamento.'**
  String get fluxPanelInstructorS2Detail;

  /// No description provided for @fluxPanelInstructorS3Label.
  ///
  /// In pt, this message translates to:
  /// **'Sala de comando'**
  String get fluxPanelInstructorS3Label;

  /// No description provided for @fluxPanelInstructorS3Detail.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar sessão, libertar blocos, repescagem e encerramento.'**
  String get fluxPanelInstructorS3Detail;

  /// No description provided for @fluxPanelInstructorS4Label.
  ///
  /// In pt, this message translates to:
  /// **'Participantes e acompanhamento'**
  String get fluxPanelInstructorS4Label;

  /// No description provided for @fluxPanelInstructorS4Detail.
  ///
  /// In pt, this message translates to:
  /// **'Lista de inscritos e progresso durante a sessão.'**
  String get fluxPanelInstructorS4Detail;

  /// No description provided for @fluxPanelInstitutionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo da instituição'**
  String get fluxPanelInstitutionTitle;

  /// No description provided for @fluxPanelInstitutionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Gestão de parque, vínculos com instrutores e visão dos treinos na organização.'**
  String get fluxPanelInstitutionSubtitle;

  /// No description provided for @fluxPanelInstitutionS1Label.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro e instituições'**
  String get fluxPanelInstitutionS1Label;

  /// No description provided for @fluxPanelInstitutionS1Detail.
  ///
  /// In pt, this message translates to:
  /// **'Manter dados da instituição e criar vínculos necessários.'**
  String get fluxPanelInstitutionS1Detail;

  /// No description provided for @fluxPanelInstitutionS2Label.
  ///
  /// In pt, this message translates to:
  /// **'Parque tecnológico'**
  String get fluxPanelInstitutionS2Label;

  /// No description provided for @fluxPanelInstitutionS2Detail.
  ///
  /// In pt, this message translates to:
  /// **'Declarar equipamentos em uso (evolução contínua no produto).'**
  String get fluxPanelInstitutionS2Detail;

  /// No description provided for @fluxPanelInstitutionS3Label.
  ///
  /// In pt, this message translates to:
  /// **'Instrutores na instituição'**
  String get fluxPanelInstitutionS3Label;

  /// No description provided for @fluxPanelInstitutionS3Detail.
  ///
  /// In pt, this message translates to:
  /// **'Coordenar quem ministra treinos nos seus espaços.'**
  String get fluxPanelInstitutionS3Detail;

  /// No description provided for @fluxPanelInstitutionS4Label.
  ///
  /// In pt, this message translates to:
  /// **'Indicadores agregados'**
  String get fluxPanelInstitutionS4Label;

  /// No description provided for @fluxPanelInstitutionS4Detail.
  ///
  /// In pt, this message translates to:
  /// **'Por setor, em conformidade com LGPD (sem identificar indivíduos).'**
  String get fluxPanelInstitutionS4Detail;

  /// No description provided for @fluxPanelManufacturerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo do fabricante'**
  String get fluxPanelManufacturerTitle;

  /// No description provided for @fluxPanelManufacturerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Dono do conhecimento técnico: catálogo, conteúdo oficial e rede de instrutores homologados.'**
  String get fluxPanelManufacturerSubtitle;

  /// No description provided for @fluxPanelManufacturerS1Label.
  ///
  /// In pt, this message translates to:
  /// **'Perfil da empresa'**
  String get fluxPanelManufacturerS1Label;

  /// No description provided for @fluxPanelManufacturerS1Detail.
  ///
  /// In pt, this message translates to:
  /// **'Dados corporativos e contacto de suporte.'**
  String get fluxPanelManufacturerS1Detail;

  /// No description provided for @fluxPanelManufacturerS2Label.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo de equipamentos'**
  String get fluxPanelManufacturerS2Label;

  /// No description provided for @fluxPanelManufacturerS2Detail.
  ///
  /// In pt, this message translates to:
  /// **'Modelos homologados para treinos e instituições.'**
  String get fluxPanelManufacturerS2Detail;

  /// No description provided for @fluxPanelManufacturerS3Label.
  ///
  /// In pt, this message translates to:
  /// **'Banco de treinamentos oficiais'**
  String get fluxPanelManufacturerS3Label;

  /// No description provided for @fluxPanelManufacturerS3Detail.
  ///
  /// In pt, this message translates to:
  /// **'Questionários padronizados por equipamento.'**
  String get fluxPanelManufacturerS3Detail;

  /// No description provided for @fluxPanelManufacturerS4Label.
  ///
  /// In pt, this message translates to:
  /// **'Homologação de instrutores'**
  String get fluxPanelManufacturerS4Label;

  /// No description provided for @fluxPanelManufacturerS4Detail.
  ///
  /// In pt, this message translates to:
  /// **'Taxa e validação da rede Application.'**
  String get fluxPanelManufacturerS4Detail;

  /// No description provided for @fluxPanelManufacturerS5Label.
  ///
  /// In pt, this message translates to:
  /// **'Analytics e gamificação'**
  String get fluxPanelManufacturerS5Label;

  /// No description provided for @fluxPanelManufacturerS5Detail.
  ///
  /// In pt, this message translates to:
  /// **'Desempenho agregado e rankings.'**
  String get fluxPanelManufacturerS5Detail;

  /// No description provided for @fluxPanelWeeklyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resumo semanal por e-mail'**
  String get fluxPanelWeeklyTitle;

  /// No description provided for @fluxPanelWeeklySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Indicadores agregados (LGPD), segundas de manhã. Pode desativar aqui.'**
  String get fluxPanelWeeklySubtitle;

  /// No description provided for @fluxPanelPrefSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível guardar a preferência.'**
  String get fluxPanelPrefSaveFailed;

  /// No description provided for @fluxPanelRoadmapBadge.
  ///
  /// In pt, this message translates to:
  /// **'roadmap'**
  String get fluxPanelRoadmapBadge;

  /// No description provided for @errApiNetworkUnreachable.
  ///
  /// In pt, this message translates to:
  /// **'Sem ligação ao servidor. Verifique a rede e a URL da API. ({detail})'**
  String errApiNetworkUnreachable(Object detail);

  /// No description provided for @errApiInvalidHttpBody.
  ///
  /// In pt, this message translates to:
  /// **'Resposta inválida do servidor (HTTP {code}).'**
  String errApiInvalidHttpBody(Object code);

  /// No description provided for @errApiResponseNotList.
  ///
  /// In pt, this message translates to:
  /// **'Resposta não é uma lista.'**
  String get errApiResponseNotList;

  /// No description provided for @errApiOperationIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a operação.'**
  String get errApiOperationIncomplete;

  /// No description provided for @errApiUploadMissingFileSource.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um ficheiro ou indique os dados do ficheiro para enviar.'**
  String get errApiUploadMissingFileSource;

  /// No description provided for @errAuthInvalidLoginResponse.
  ///
  /// In pt, this message translates to:
  /// **'Resposta de login inválida.'**
  String get errAuthInvalidLoginResponse;

  /// No description provided for @errAuthInvalidRegisterResponse.
  ///
  /// In pt, this message translates to:
  /// **'Resposta de cadastro inválida.'**
  String get errAuthInvalidRegisterResponse;

  /// No description provided for @errAuthGoogleCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Login Google cancelado.'**
  String get errAuthGoogleCancelled;

  /// No description provided for @errAuthInvalidGoogleLoginResponse.
  ///
  /// In pt, this message translates to:
  /// **'Resposta de login Google inválida.'**
  String get errAuthInvalidGoogleLoginResponse;

  /// No description provided for @errGoogleNoIdToken.
  ///
  /// In pt, this message translates to:
  /// **'Google não devolveu id_token. Verifique o Client ID Web e as APIs no Google Cloud.'**
  String get errGoogleNoIdToken;

  /// No description provided for @errGoogleSignInFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha no login Google: {detail}'**
  String errGoogleSignInFailed(Object detail);

  /// No description provided for @loginDebugApiLine.
  ///
  /// In pt, this message translates to:
  /// **'API: {url}'**
  String loginDebugApiLine(Object url);

  /// No description provided for @mfgDocSizeBytes.
  ///
  /// In pt, this message translates to:
  /// **'{size} B'**
  String mfgDocSizeBytes(Object size);

  /// No description provided for @mfgDocSizeKb.
  ///
  /// In pt, this message translates to:
  /// **'{size} KB'**
  String mfgDocSizeKb(Object size);

  /// No description provided for @mfgDocSizeMb.
  ///
  /// In pt, this message translates to:
  /// **'{size} MB'**
  String mfgDocSizeMb(Object size);

  /// No description provided for @trnCertCodeFallback.
  ///
  /// In pt, this message translates to:
  /// **'certificado'**
  String get trnCertCodeFallback;

  /// No description provided for @trnCertDownloadFilename.
  ///
  /// In pt, this message translates to:
  /// **'certificado-{code}'**
  String trnCertDownloadFilename(Object code);

  /// No description provided for @dashExportFileInstitutionCsv.
  ///
  /// In pt, this message translates to:
  /// **'appcation-instituicao-{stamp}.csv'**
  String dashExportFileInstitutionCsv(Object stamp);

  /// No description provided for @dashExportFileInstitutionPdf.
  ///
  /// In pt, this message translates to:
  /// **'appcation-instituicao-{stamp}.pdf'**
  String dashExportFileInstitutionPdf(Object stamp);

  /// No description provided for @dashExportFileManufacturerCsv.
  ///
  /// In pt, this message translates to:
  /// **'appcation-fabricante-{stamp}.csv'**
  String dashExportFileManufacturerCsv(Object stamp);

  /// No description provided for @dashExportFileManufacturerPdf.
  ///
  /// In pt, this message translates to:
  /// **'appcation-fabricante-{stamp}.pdf'**
  String dashExportFileManufacturerPdf(Object stamp);

  /// No description provided for @utilDownloadWebOnly.
  ///
  /// In pt, this message translates to:
  /// **'O download de ficheiros só está disponível na versão Web.'**
  String get utilDownloadWebOnly;

  /// No description provided for @loginIamManufacturer.
  ///
  /// In pt, this message translates to:
  /// **'Sou fabricante'**
  String get loginIamManufacturer;

  /// No description provided for @loginIamInstitution.
  ///
  /// In pt, this message translates to:
  /// **'Sou instituição'**
  String get loginIamInstitution;

  /// No description provided for @loginIamInstructorLink.
  ///
  /// In pt, this message translates to:
  /// **'Sou instrutor (Application)'**
  String get loginIamInstructorLink;

  /// No description provided for @loginInstitutionFootnote.
  ///
  /// In pt, this message translates to:
  /// **'Gestores acedem com credenciais criadas pela instituição ou fabricante. Para novo registo como equipa clínica, utilize «Começar agora» como instrutor e peça vínculo ao hospital.'**
  String get loginInstitutionFootnote;

  /// No description provided for @mfgOnboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro de fabricante'**
  String get mfgOnboardTitle;

  /// No description provided for @mfgOnboardStepCounter.
  ///
  /// In pt, this message translates to:
  /// **'Passo {step} de {total}'**
  String mfgOnboardStepCounter(int step, int total);

  /// No description provided for @mfgOnboardCorporateSection.
  ///
  /// In pt, this message translates to:
  /// **'Dados corporativos'**
  String get mfgOnboardCorporateSection;

  /// No description provided for @mfgFieldLegalName.
  ///
  /// In pt, this message translates to:
  /// **'Razão social'**
  String get mfgFieldLegalName;

  /// No description provided for @mfgFieldTradeName.
  ///
  /// In pt, this message translates to:
  /// **'Nome fantasia'**
  String get mfgFieldTradeName;

  /// No description provided for @mfgFieldStateRegistration.
  ///
  /// In pt, this message translates to:
  /// **'Inscrição estadual'**
  String get mfgFieldStateRegistration;

  /// No description provided for @mfgFieldWebsite.
  ///
  /// In pt, this message translates to:
  /// **'Site institucional'**
  String get mfgFieldWebsite;

  /// No description provided for @mfgFieldCommercialPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone comercial'**
  String get mfgFieldCommercialPhone;

  /// No description provided for @mfgAddressSection.
  ///
  /// In pt, this message translates to:
  /// **'Endereço'**
  String get mfgAddressSection;

  /// No description provided for @mfgFieldCep.
  ///
  /// In pt, this message translates to:
  /// **'CEP'**
  String get mfgFieldCep;

  /// No description provided for @mfgCepLookup.
  ///
  /// In pt, this message translates to:
  /// **'Buscar CEP'**
  String get mfgCepLookup;

  /// No description provided for @mfgFieldStreet.
  ///
  /// In pt, this message translates to:
  /// **'Logradouro'**
  String get mfgFieldStreet;

  /// No description provided for @mfgFieldNeighborhood.
  ///
  /// In pt, this message translates to:
  /// **'Bairro'**
  String get mfgFieldNeighborhood;

  /// No description provided for @mfgFieldCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get mfgFieldCity;

  /// No description provided for @mfgFieldState.
  ///
  /// In pt, this message translates to:
  /// **'UF'**
  String get mfgFieldState;

  /// No description provided for @mfgOnboardLegalRepSection.
  ///
  /// In pt, this message translates to:
  /// **'Representante legal'**
  String get mfgOnboardLegalRepSection;

  /// No description provided for @mfgFieldLegalRepName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get mfgFieldLegalRepName;

  /// No description provided for @mfgFieldLegalRepCpf.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get mfgFieldLegalRepCpf;

  /// No description provided for @mfgFieldLegalRepRole.
  ///
  /// In pt, this message translates to:
  /// **'Cargo'**
  String get mfgFieldLegalRepRole;

  /// No description provided for @mfgFieldLegalRepPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone direto'**
  String get mfgFieldLegalRepPhone;

  /// No description provided for @mfgOnboardDocsSection.
  ///
  /// In pt, this message translates to:
  /// **'Documentos para validação'**
  String get mfgOnboardDocsSection;

  /// No description provided for @mfgDocFormatsHint.
  ///
  /// In pt, this message translates to:
  /// **'Formatos aceites: PDF, JPG, PNG (máx. 10 MB cada).'**
  String get mfgDocFormatsHint;

  /// No description provided for @mfgDocCnpjProof.
  ///
  /// In pt, this message translates to:
  /// **'Comprovante de inscrição no CNPJ'**
  String get mfgDocCnpjProof;

  /// No description provided for @mfgDocArticles.
  ///
  /// In pt, this message translates to:
  /// **'Contrato social (ou equivalente)'**
  String get mfgDocArticles;

  /// No description provided for @mfgDocAddressProof.
  ///
  /// In pt, this message translates to:
  /// **'Comprovante de endereço (água/luz, até 3 meses)'**
  String get mfgDocAddressProof;

  /// No description provided for @mfgDeclarationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Declaro que todas as informações são verdadeiras e que a falsidade implica responsabilização legal.'**
  String get mfgDeclarationLabel;

  /// No description provided for @mfgSendForReview.
  ///
  /// In pt, this message translates to:
  /// **'Enviar para análise'**
  String get mfgSendForReview;

  /// No description provided for @mfgPendingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro em análise'**
  String get mfgPendingTitle;

  /// No description provided for @mfgPendingBody.
  ///
  /// In pt, this message translates to:
  /// **'Os seus documentos foram enviados com sucesso e estão a ser analisados pela nossa equipa.'**
  String get mfgPendingBody;

  /// No description provided for @mfgPendingSla.
  ///
  /// In pt, this message translates to:
  /// **'Prazo estimado: 24 a 48 horas úteis.'**
  String get mfgPendingSla;

  /// No description provided for @mfgPendingEmailNotice.
  ///
  /// In pt, this message translates to:
  /// **'Receberá um e-mail assim que o cadastro for aprovado.'**
  String get mfgPendingEmailNotice;

  /// No description provided for @mfgPendingProtocol.
  ///
  /// In pt, this message translates to:
  /// **'N.º do protocolo'**
  String get mfgPendingProtocol;

  /// No description provided for @mfgPendingStatusReview.
  ///
  /// In pt, this message translates to:
  /// **'Estado: em análise'**
  String get mfgPendingStatusReview;

  /// No description provided for @mfgPendingSubmittedAt.
  ///
  /// In pt, this message translates to:
  /// **'Enviado em'**
  String get mfgPendingSubmittedAt;

  /// No description provided for @mfgPendingSupport.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda: suporte@app2cation.com'**
  String get mfgPendingSupport;

  /// No description provided for @mfgCepInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um CEP com 8 dígitos.'**
  String get mfgCepInvalid;

  /// No description provided for @mfgCepNotFound.
  ///
  /// In pt, this message translates to:
  /// **'CEP não encontrado.'**
  String get mfgCepNotFound;

  /// No description provided for @mfgPickDoc.
  ///
  /// In pt, this message translates to:
  /// **'Anexar ficheiro'**
  String get mfgPickDoc;

  /// No description provided for @mfgRemoveDoc.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get mfgRemoveDoc;

  /// No description provided for @mfgLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get mfgLogout;

  /// No description provided for @mfgOnboardFieldsRequired.
  ///
  /// In pt, this message translates to:
  /// **'Preencha todos os campos obrigatórios (CNPJ com 14 dígitos, CEP com 8, UF com 2 letras).'**
  String get mfgOnboardFieldsRequired;

  /// No description provided for @mfgAcceptDeclaration.
  ///
  /// In pt, this message translates to:
  /// **'Aceite a declaração para enviar o cadastro para análise.'**
  String get mfgAcceptDeclaration;

  /// No description provided for @mfgDocMissingKind.
  ///
  /// In pt, this message translates to:
  /// **'Documento em falta: {title}'**
  String mfgDocMissingKind(Object title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
