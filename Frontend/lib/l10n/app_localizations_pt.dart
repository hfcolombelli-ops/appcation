// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Appcation';

  @override
  String get loginShellTitle => 'Login Universal';

  @override
  String get loginBrandTitle => 'App²cation';

  @override
  String get loginTagline => 'Treino clínico com ritmo e clareza';

  @override
  String get loginAccessHeroTitle => 'Acesse o App²cation';

  @override
  String get loginAccessHeroSubtitle =>
      'Plataforma de gestão de treinamentos para equipamentos hospitalares';

  @override
  String get loginCardSignInHeadline => 'Entre na sua conta';

  @override
  String get loginCardSignInLead =>
      'Use o Google ou o e-mail e senha da sua instituição.';

  @override
  String get loginUrsSecurePortalSubtitle => 'Acesso seguro ao portal';

  @override
  String get loginSectionLoginTitle => 'Login';

  @override
  String get loginInstitutionalCredentialsTitle => 'Credenciais (e-mail)';

  @override
  String get loginFieldIdentifier => 'Identificador';

  @override
  String get loginFieldIdentifierHint =>
      'CPF, CRM, CNPJ ou e-mail da instituição';

  @override
  String get loginIdentityPatient => 'Perfil: treinando (CPF válido)';

  @override
  String get loginIdentityInstitution =>
      'Perfil: instituição / fabricante (CNPJ)';

  @override
  String get loginIdentityDoctor => 'Perfil: instrutor (CRM)';

  @override
  String get loginIdentitySystem => 'Conta interna (login alfanumérico)';

  @override
  String get loginIdentityEmail => 'E-mail institucional';

  @override
  String get loginIdentityUnknown =>
      'Identificador não reconhecido — use e-mail válido ou Google';

  @override
  String get loginForgotPassword => 'Esqueci minha senha';

  @override
  String get loginNoAccountPrefix => 'Não tem conta?';

  @override
  String get loginNoAccountAction => 'Criar conta';

  @override
  String get loginUrsHeroTagline =>
      'Conectando cuidado e tecnologia em tempo real';

  @override
  String get loginEmptyIdentifierPassword =>
      'Identificador ou senha em branco.';

  @override
  String get loginIdentifierInvalidClient =>
      'Identificador inválido. Use CPF, CRM, CNPJ válido, login administrativo ou e-mail.';

  @override
  String get loginPasswordRequiresEmail =>
      'Para entrar com senha neste portal, use o e-mail da sua conta (ou Continuar com Google).';

  @override
  String get loginShowPassword => 'Mostrar senha';

  @override
  String get loginHidePassword => 'Ocultar senha';

  @override
  String get loginNavQuestions => 'Dúvidas?';

  @override
  String get loginNavStartNow => 'Começar agora';

  @override
  String get loginNavHaveAccount => 'Já tenho conta';

  @override
  String get loginFooterTerms => 'Termos de uso';

  @override
  String get loginFooterPrivacy => 'Política de privacidade';

  @override
  String get loginFooterCookies => 'Cookies';

  @override
  String get loginFooterHelp => 'Centro de ajuda';

  @override
  String get loginFooterSystemsOk => 'Todos os sistemas operacionais';

  @override
  String get loginFooterSupportPrefix => 'Não consegue aceder?';

  @override
  String get loginFooterSupportLink => 'Fale com o suporte técnico';

  @override
  String get loginFooterSoon => 'Disponível em breve.';

  @override
  String get authTrackCpfLabel => 'CPF';

  @override
  String get authTrackCnpjLabel => 'CNPJ';

  @override
  String get authTrackSegmentSubtitle =>
      'Pessoa física (treinando ou instrutor) ou empresa (fabricante). Gestor de instituição só por convite no painel.';

  @override
  String get loginGoogleProfileSection => 'Perfil (primeiro acesso Google)';

  @override
  String get loginGoogleProfileSectionCpf =>
      'Google — pessoa física (treinando ou instrutor)';

  @override
  String get loginGoogleProfileSectionCnpj =>
      'Google — fabricante (empresa / CNPJ)';

  @override
  String get googleRoleTrainee => 'Treinando';

  @override
  String get googleRoleInstructor => 'Instrutor';

  @override
  String get googleRoleInstitutionAdmin => 'Gestor';

  @override
  String get googleRoleManufacturerAdmin => 'Fabricante';

  @override
  String get mfgCompanyLabel => 'Empresa (fabricante)';

  @override
  String get mfgCnpjOptionalLabel => 'CNPJ (opcional)';

  @override
  String get institutionLoadingGoogle =>
      'A carregar instituições… Se a lista estiver vazia, registe primeiro uma instituição (conta instrutor) ou use e-mail e senha.';

  @override
  String get institutionPickerLabelGoogle => 'Instituição (gestor)';

  @override
  String get googleConnecting => 'A ligar ao Google…';

  @override
  String get googleContinue => 'Continuar com Google';

  @override
  String get loginOrEmail => 'ou e-mail';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPassword => 'Senha';

  @override
  String get valEmailRequired => 'Informe o e-mail.';

  @override
  String get valEmailInvalid => 'E-mail inválido.';

  @override
  String get valPasswordRequired => 'Informe a senha.';

  @override
  String get actionSignIn => 'Entrar';

  @override
  String get loginOrgHint =>
      'Gestor de hospital ou clínica: use o e-mail e senha que a instituição criou para si no painel interno.';

  @override
  String get actionCreateAccount => 'Criar conta';

  @override
  String get actionBack => 'Voltar';

  @override
  String get registerSubtitle =>
      'Escolha CPF ou CNPJ, o perfil e preencha os dados.';

  @override
  String get registerAccountTypeTitle => 'Tipo de conta';

  @override
  String get registerAccountTypeTitleCpf => 'Perfil (CPF)';

  @override
  String get registerAccountTypeTitleCnpj => 'Conta fabricante (CNPJ)';

  @override
  String get registerManagerInviteHint =>
      'Gestor de instituição não se cadastra aqui: o hospital ou fabricante cria o acesso no painel.';

  @override
  String get registerInstitutionsLoading =>
      'A carregar instituições… Se a lista estiver vazia, ainda não há hospitais registados na API.';

  @override
  String get fieldInstitution => 'Instituição';

  @override
  String get fieldFullName => 'Nome completo';

  @override
  String get valNameRequired => 'Informe o nome.';

  @override
  String get fieldPasswordRegister => 'Senha (mín. 8 caracteres)';

  @override
  String get valPasswordMin8 => 'Mínimo 8 caracteres.';

  @override
  String get fieldCompanyName => 'Nome da empresa';

  @override
  String get registerMfgCompanyOptionalDomain =>
      'Obrigatório só no primeiro registo deste domínio; deixe em branco para juntar-se a um fabricante já criado.';

  @override
  String get valCompanyNameRequired => 'Informe o nome da empresa.';

  @override
  String get actionCompleteRegistration => 'Concluir cadastro';

  @override
  String get errApiConnection => 'Falha de conexão com a API.';

  @override
  String get errMfgNameRequired => 'Informe o nome da empresa.';

  @override
  String get errSelectInstitution => 'Selecione a instituição na lista.';

  @override
  String get errGoogleClientId =>
      'Configure GOOGLE_WEB_CLIENT_ID ao executar o Flutter (mesmo ID que GOOGLE_CLIENT_ID no servidor).';

  @override
  String get errMfgNameBeforeGoogle =>
      'Informe o nome do fabricante antes de continuar com Google.';

  @override
  String get errSelectInstitutionGoogle =>
      'Selecione a instituição na lista (ou aguarde o carregamento).';

  @override
  String get shellTitleOverview => 'Visão Geral';

  @override
  String get shellTitleCommandRoom => 'Sala de Comando';

  @override
  String get shellTitleNewTraining => 'Novo Treinamento';

  @override
  String get shellTitleCredentialing => 'Credenciamento';

  @override
  String get shellTitleTrainingRequests => 'Pedidos de treino';

  @override
  String get shellTitleTechPark => 'Parque tecnológico';

  @override
  String get shellTitleEndorsements => 'Endossos ao fabricante';

  @override
  String get shellTitleFluxxoReview => 'Revisão de fabricantes';

  @override
  String get shellNavDashboard => 'Dashboard';

  @override
  String get shellNavCommandRoom => 'Sala de Comando';

  @override
  String get shellNavTrainings => 'Treinamentos';

  @override
  String get shellNavTrainingRequests => 'Pedidos de treino';

  @override
  String get shellNavTechPark => 'Parque tecnológico';

  @override
  String get shellNavEndorsementsShort => 'Endossos fabricante';

  @override
  String get shellNavFluxxoReview => 'Fabricantes';

  @override
  String get shellNavCredentialing => 'Credenciamento';

  @override
  String get shellNavPostTrainingResults => 'Resultados do treino';

  @override
  String get shellTitlePostTrainingResults => 'Resultados e repescagem';

  @override
  String get postTrainingIntro =>
      'Revise participantes após a sessão, aplique repescagem a quem precisar e finalize quando todos estiverem avaliados. O controlo em tempo real permanece na Sala de comando.';

  @override
  String get postTrainingPickTraining =>
      'Escolha um treino para carregar a lista de inscritos.';

  @override
  String get postTrainingOutcomeApproved => 'Aprovado (≥ 7,0)';

  @override
  String get postTrainingOutcomeInsufficient => 'Insuficiente (< 7,0)';

  @override
  String get postTrainingOutcomeRecovery => 'Em recuperação';

  @override
  String get postTrainingOutcomeInProgress => 'Em curso';

  @override
  String get postTrainingOutcomeWaitingRoom => 'Sala de espera';

  @override
  String get postTrainingOutcomeCompletedNoGrade => 'Concluído (sem nota)';

  @override
  String get postTrainingFinishTraining => 'Encerrar treino';

  @override
  String get postTrainingFinishTrainingConfirmTitle => 'Encerrar este treino?';

  @override
  String get postTrainingFinishTrainingConfirmBody =>
      'O estado passa a concluído. Os treinandos deixam de responder ao questionário nesta sessão.';

  @override
  String get postTrainingFinishTrainingDone =>
      'Treino concluído. Certificados garantidos para quem tem nota ≥ limiar.';

  @override
  String get postTrainingCertificatePdfTooltip =>
      'Descarregar certificado (PDF)';

  @override
  String get postTrainingIssueCertificate => 'Emitir certificado';

  @override
  String get postTrainingIssueCertificateTooltip =>
      'Registar o certificado na base quando a nota já é ≥ ao limiar (ex.: correção após encerramento).';

  @override
  String get postTrainingIssueCertificateDone => 'Certificado emitido.';

  @override
  String get postTrainingIssueCertificateAlready =>
      'Este participante já tinha certificado.';

  @override
  String get postTrainingExportCertificatesCsvTooltip =>
      'Descarregar CSV com inscritos e certificados deste treino (auditoria).';

  @override
  String get postTrainingExportCertificatesDone =>
      'Relatório CSV descarregado.';

  @override
  String postTrainingExportCertificatesCsvFilename(
    int trainingId,
    String stamp,
  ) {
    return 'appcation-treino-$trainingId-$stamp.csv';
  }

  @override
  String get postTrainingExportCertificatesPdfTooltip =>
      'Descarregar PDF com inscritos e certificados deste treino (auditoria).';

  @override
  String get postTrainingExportCertificatesPdfDone =>
      'Relatório PDF descarregado.';

  @override
  String postTrainingExportCertificatesPdfFilename(
    int trainingId,
    String stamp,
  ) {
    return 'appcation-treino-$trainingId-$stamp.pdf';
  }

  @override
  String get shellLinkInstitutionTitle => 'Vincule a sua instituição';

  @override
  String get shellLinkInstitutionBody =>
      'Sem isto não vê pedidos de treino nem o dashboard agregado.';

  @override
  String get shellLinkInstitutionEmpty =>
      'Não há instituições na API — crie uma em Credenciamento (como instrutor) ou peça ao administrador.';

  @override
  String get shellSaveLink => 'Guardar vínculo';

  @override
  String get shellPickInstitution => 'Escolha a instituição.';

  @override
  String get shellAreaManager => 'Área do gestor';

  @override
  String get shellAreaInstructor => 'Área do instrutor';

  @override
  String get shellDefaultUserName => 'Instrutor';

  @override
  String get actionSignOut => 'Sair';

  @override
  String get profileGateTitle => 'Perfil não reconhecido';

  @override
  String get profileGateBody =>
      'A sessão está ativa, mas este utilizador não tem um perfil associado a uma área da aplicação (treinando, instrutor, gestor ou fabricante). Termine a sessão e entre novamente; no primeiro acesso com Google, escolha o tipo de conta correto.';

  @override
  String get profileGateDocHint =>
      'Fluxo oficial do produto: docs/product/fluxo_app2cation.mermaid';

  @override
  String get profileGateYourAccount => 'Conta com sessão iniciada';

  @override
  String profileGateRoleFromApi(Object role) {
    return 'Função (role) no servidor: $role';
  }

  @override
  String get profileGateRefreshSession => 'Actualizar sessão';

  @override
  String get profileGateRefreshHint =>
      'Use depois de um administrador actualizar a sua função — sem voltar a escrever a palavra-passe.';

  @override
  String get profileGateClaimSectionTitle => 'Definir perfil (uma vez)';

  @override
  String get profileGateClaimIntro =>
      'Se a sua conta deve ser treinando, instrutor ou administrador de fabricante mas a função no servidor estava em falta ou inválida, escolha abaixo. Só é permitido até existir uma função válida gravada.';

  @override
  String get profileGateClaimHint =>
      'Gestor de instituição não se define aqui — o hospital ou o fabricante cria esse acesso.';

  @override
  String get profileGateChooseRole => 'Perfil na plataforma';

  @override
  String get profileGateConfirmProfile => 'Confirmar perfil';

  @override
  String get profileGatePickRoleFirst => 'Escolha um perfil primeiro.';

  @override
  String get profileGateSnackUseRefresh =>
      'Use «Actualizar sessão» para continuar.';

  @override
  String get loginGoogleTriageHint =>
      'Depois de entrar com o Google, escolhe o teu perfil em dois passos (tipo de conta e, se necessário, dados da empresa).';

  @override
  String get profileTriageTitle => 'Escolhe o teu perfil';

  @override
  String get profileTriageSubtitle =>
      'Selecciona o tipo de conta. No passo seguinte confirmas ou completas os dados para vincular a conta Google.';

  @override
  String get profileTriageStep2Title => 'Dados do perfil';

  @override
  String get profileTriageTraineeBody =>
      'Como treinando participas em sessões com código, respondes ao questionário e acedes a certificados.';

  @override
  String get profileTriageInstructorBody =>
      'Como instrutor crias e conduzes treinos e credencias-te em instituições e fabricantes quando aplicável.';

  @override
  String get profileTriageManufacturerBody =>
      'Indica o nome público da empresa e, opcionalmente, o CNPJ. O domínio do teu e-mail determina a área de fabricante.';

  @override
  String get profileTriageBack => 'Alterar tipo de perfil';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get dashLinkInstitutionForKpis =>
      'Associe a sua instituição no aviso laranja no topo para ver indicadores agregados.';

  @override
  String get dashKpiTrainings => 'Treinamentos';

  @override
  String get dashKpiFinished => 'Encerrados';

  @override
  String get dashKpiUniqueParticipants => 'Participantes únicos';

  @override
  String get dashKpiAvgCompleted => 'Média (concluídos)';

  @override
  String get dashKpiApprovalRate => 'Taxa aprovação';

  @override
  String get dashSeasonRankingTitle => 'Ranking por temporada';

  @override
  String get dashSeasonRankingHint =>
      'Treinos oficiais ligados a fabricantes contam para as temporadas definidas pelo fabricante.';

  @override
  String get dashRecentTrainings => 'Treinamentos recentes';

  @override
  String get dashNoTrainingsYet =>
      'Nenhum treinamento ainda. Crie um em Treinamentos.';

  @override
  String dashSeasonPoints(Object points) {
    return '$points pts';
  }

  @override
  String get dashInstitutionKpisTitle => 'Indicadores da instituição';

  @override
  String get dashInstitutionLgpdNote =>
      'Dados agregados — sem identificação individual (LGPD).';

  @override
  String get dashInstitutionAlertPendingTitle => 'Pedidos por rever';

  @override
  String dashInstitutionAlertPendingBody(int count) {
    return 'Existem $count pedido(s) pendente(s) na fila. Abra o quadro para rever e agendar.';
  }

  @override
  String get dashInstitutionShortcutsTitle => 'Áreas do gestor';

  @override
  String get dashExportCsv => 'Exportar CSV';

  @override
  String get dashExportPdf => 'Exportar PDF';

  @override
  String get dashKpiPendingRequests => 'Pedidos pendentes';

  @override
  String get dashKpiInstitutionTrainings => 'Treinos (instituição)';

  @override
  String get dashKpiEnrollmentsTotal => 'Inscrições (total)';

  @override
  String get dashKpiCompleted => 'Concluídas';

  @override
  String get dashKpiCompletionRate => 'Taxa conclusão';

  @override
  String get dashKpiAvgScoreOverall => 'Média notas (geral)';

  @override
  String get dashByEquipment => 'Por equipamento';

  @override
  String get dashNoEquipmentData => 'Sem dados por equipamento ainda.';

  @override
  String dashEquipmentSubtitle(
    Object enr,
    Object done,
    Object rate,
    Object avg,
  ) {
    return 'Inscrições: $enr · Concl.: $done · Taxa: $rate% · Média nota: $avg';
  }

  @override
  String get dashSectorAveragesTitle => 'Por setor (treinos da instituição)';

  @override
  String get dashNoSectorHistory => 'Sem histórico por setor.';

  @override
  String dashSectorSubtitle(int total, int done, int scored, String avg) {
    return 'Inscrições: $total · Concluídas: $done · Com nota: $scored · Média: $avg';
  }

  @override
  String get trainingSectionTitle => 'Configuração';

  @override
  String get trainingFieldTitle => 'Título do treinamento';

  @override
  String get trainingTypeOfficial => 'Oficial';

  @override
  String get trainingTypeCustom => 'Personalizado';

  @override
  String get trainingScheduledLabel => 'Data/hora (opcional)';

  @override
  String get trainingScheduledHint => 'AAAA-MM-DD HH:MM';

  @override
  String get trainingCreateButton => 'Criar treinamento';

  @override
  String get trainingTemplateCardTitle => 'Template oficial (fabricante)';

  @override
  String get trainingTemplateCardBody =>
      'Clona o questionário homologado. Requer homologação aprovada com o fabricante.';

  @override
  String get trainingTemplateLabel => 'Template';

  @override
  String get trainingUseTemplateButton =>
      'Usar template na instituição selecionada';

  @override
  String get trainingJoinCodeTitle =>
      'Código de entrada (repasse aos treinandos)';

  @override
  String trainingInternalId(Object id) {
    return 'ID interno: $id';
  }

  @override
  String get trainingPostRepescageTitle => 'Nota após repescagem';

  @override
  String get trainingPostRepescageBody =>
      'Substituir vs média: «só repescagem» usa apenas as questões da última libertação de erros; «média global» mantém a média de todas as questões já libertadas.';

  @override
  String get trainingPolicyFinalLabel => 'Política de nota final';

  @override
  String get trainingPolicyFullAverage =>
      'Média global (todas as questões libertadas)';

  @override
  String get trainingPolicyRecoveryOnly =>
      'Só repescagem (substitui a média global)';

  @override
  String get trainingVariantBankTitle => 'Banco de variantes (repescagem)';

  @override
  String get trainingVariantBankSubtitle =>
      'Se as perguntas tiverem o mesmo grupo de variantes no questionário, na repescagem propõe outra pergunta equivalente em vez de repetir a mesma.';

  @override
  String get trainingSavePolicyButton => 'Guardar política';

  @override
  String get trainingQuestionnaireTitle => 'Questionário';

  @override
  String get trainingDefaultQuestionnaireBlockTitle => 'Avaliação';

  @override
  String get trainLifecycleDraft => 'Rascunho';

  @override
  String get trainLifecycleScheduled => 'Agendado';

  @override
  String get trainLifecycleInProgress => 'Em curso';

  @override
  String get trainLifecycleFinished => 'Concluído';

  @override
  String get trainLifecycleCancelled => 'Cancelado';

  @override
  String get enrollmentStatusWaiting => 'Em espera';

  @override
  String get enrollmentStatusActive => 'Ativo';

  @override
  String get enrollmentStatusCompleted => 'Concluído';

  @override
  String get trainingAddQuestion => 'Pergunta';

  @override
  String get trainingSaveQuestionnaireApi => 'Salvar questionário na API';

  @override
  String get trainingSnackPolicySaved =>
      'Política de nota (repescagem) guardada.';

  @override
  String get trainingSnackFromTemplate =>
      'Treinamento criado a partir do template oficial.';

  @override
  String get trainingPickInstitution => 'Selecione uma instituição.';

  @override
  String get trainingErrTitle => 'Informe o título.';

  @override
  String get trainingErrQuestionCorrect =>
      'Cada pergunta precisa de uma opção correta.';

  @override
  String get trainingErrQuestionValid =>
      'Adicione ao menos uma pergunta válida com 2+ opções.';

  @override
  String get trainingSnackQuestionnaireSaved => 'Questionário salvo.';

  @override
  String trainingQuestionN(Object n) {
    return 'Pergunta $n';
  }

  @override
  String get trainingPromptLabel => 'Enunciado';

  @override
  String get trainingOptionsMarkCorrect => 'Opções (marque a correta)';

  @override
  String trainingOptionN(Object n) {
    return 'Opção $n';
  }

  @override
  String get comandoSnackBlockReleased =>
      'Próximo bloco liberado (ou já não há blocos pendentes).';

  @override
  String get comandoSessionPaused => 'Sessão pausada para os treinandos.';

  @override
  String get comandoSessionResumed => 'Sessão retomada.';

  @override
  String comandoStatusUpdate(Object status) {
    return 'Status: $status';
  }

  @override
  String get comandoSnackRepescageDone =>
      'Repescagem aplicada — participantes podem corrigir respostas erradas.';

  @override
  String get comandoActiveTraining => 'Treinamento ativo';

  @override
  String comandoTrainingStatusHash(Object status, Object hash) {
    return 'Status: $status · Hash: $hash';
  }

  @override
  String get comandoParticipantsTitle => 'Participantes';

  @override
  String get comandoParticipantsSearchHint => 'Filtrar por nome ou e-mail';

  @override
  String get comandoParticipantsNoMatch =>
      'Nenhum participante corresponde a este filtro.';

  @override
  String get comandoNoParticipants => 'Nenhum participante inscrito.';

  @override
  String get comandoSessionControlTitle => 'Controle da sessão';

  @override
  String get comandoRepescageScope => 'Âmbito da repescagem';

  @override
  String get comandoRepescageScopeAll =>
      'Todo o treino (todas as respostas erradas)';

  @override
  String get comandoBlockDefault => 'Bloco';

  @override
  String get comandoBtnStart => 'Iniciar';

  @override
  String get comandoBtnReleaseBlock => 'Liberar próximo bloco';

  @override
  String get comandoBtnPause => 'Pausar';

  @override
  String get comandoBtnResume => 'Retomar';

  @override
  String get comandoBtnReschedule => 'Reagendar';

  @override
  String get comandoBtnClose => 'Encerrar';

  @override
  String comandoRepescageCount(Object count) {
    return 'Repescagem ($count)';
  }

  @override
  String get comandoHelpFooter =>
      'Iniciar libera o questionário para treinandos conectados. Repescagem remove respostas erradas; por bloco, só as desse bloco (etiquetas quando o acerto no bloco está abaixo de 50%).';

  @override
  String get comandoOfflineHint =>
      'Sem ligação ao servidor. Os comandos da sessão ficam indisponíveis até a API voltar; pode actualizar a lista de treinos quando estiver online.';

  @override
  String get instrOfflineHint =>
      'Sem ligação ao servidor. Actualize quando a rede voltar; operações que gravam ou exportam ficam indisponíveis até a API responder.';

  @override
  String comandoParticipantAnswers(
    Object answered,
    Object total,
    Object status,
  ) {
    return 'Respostas $answered / $total · $status';
  }

  @override
  String get comandoHeroTitle => 'Execução ao vivo';

  @override
  String get comandoHeroLiveBadge => 'Ao vivo';

  @override
  String get comandoHeroModulePrefix => 'Módulo:';

  @override
  String get comandoStatDurationLabel => 'Duração';

  @override
  String get comandoStatParticipantsLabel => 'Participantes';

  @override
  String get comandoStatActiveShort => 'Ativos';

  @override
  String get comandoStatWaitingShort => 'Em espera';

  @override
  String get comandoDurationPlaceholder => '—';

  @override
  String get comandoProgressByBlockTitle => 'Progresso por bloco';

  @override
  String get comandoColBlockTitle => 'Bloco';

  @override
  String get comandoColState => 'Estado';

  @override
  String get comandoColCompletion => 'Conclusão';

  @override
  String get comandoColAccuracy => 'Precisão';

  @override
  String get comandoBlockStateReleased => 'Liberto';

  @override
  String get comandoBlockStatePending => 'Pendente';

  @override
  String get comandoDeckSubtitle =>
      'Inicie, pause ou encerre a sessão em tempo real.';

  @override
  String get comandoDeckBadgeRunning => 'Em curso';

  @override
  String get comandoDeckBadgePaused => 'Pausado';

  @override
  String get comandoDeckBadgeScheduled => 'Agendado';

  @override
  String get comandoDeckBadgeFinished => 'Encerrado';

  @override
  String get credSnackInstitutionCreated => 'Instituição criada.';

  @override
  String get credTitleInstitutions => 'Instituições';

  @override
  String get credIntroInstitutions =>
      'Cadastre hospitais ou unidades para vincular aos treinamentos.';

  @override
  String get credFieldInstitutionName => 'Nome da instituição';

  @override
  String get credFieldCnpjUnique => 'CNPJ (único)';

  @override
  String get credBtnRegisterInstitution => 'Cadastrar instituição';

  @override
  String credListedCount(Object count) {
    return 'Cadastradas ($count)';
  }

  @override
  String get credDoubleTitle => 'Credenciamento duplo';

  @override
  String get credDoubleIntro =>
      'Vínculo com instituição e homologação pelo fabricante.';

  @override
  String get credApplyInstitutionLabel => 'Pedir vínculo à instituição';

  @override
  String get credBtnRequestInstitution => 'Solicitar vínculo institucional';

  @override
  String get credApplyManufacturerLabel => 'Pedir homologação ao fabricante';

  @override
  String get credBtnRequestManufacturer => 'Solicitar ao fabricante';

  @override
  String get credMyLinksTitle => 'Meus vínculos';

  @override
  String get credMyLinksInstitutionsHeader => 'Instituições';

  @override
  String get credNoInstitutionalLink => 'Nenhum vínculo institucional.';

  @override
  String get credMyLinksManufacturersHeader => 'Fabricantes';

  @override
  String get credNoManufacturerHomologation =>
      'Nenhuma homologação junto a fabricantes.';

  @override
  String get credQueueInstTitle => 'Pedidos de vínculo (gestor)';

  @override
  String get credQueueInstBody =>
      'Instrutores que pediram vínculo com a sua instituição. O estado «Pendente» desaparece da fila após decidir.';

  @override
  String get credQueueManuTitle => 'Homologações pendentes (fabricante)';

  @override
  String get credQueueManuBody =>
      'Homologação de instrutores junto do fabricante. Verifique o endosso da instituição antes de aprovar.';

  @override
  String get credBtnApprove => 'Aprovar';

  @override
  String get credBtnSuspend => 'Suspender';

  @override
  String get credBtnReactivateHomolog => 'Reactivar';

  @override
  String get credStatusSuspended => 'Suspenso';

  @override
  String get credBtnReject => 'Recusar';

  @override
  String credEndorsementWith(Object name) {
    return 'Endosso institucional: $name';
  }

  @override
  String get credEndorsementPending => 'Endosso institucional: pendente';

  @override
  String get credSnackRequestSent => 'Pedido enviado.';

  @override
  String get credSnackRequestManufacturerSent =>
      'Pedido enviado ao fabricante.';

  @override
  String get credStatusPending => 'Pendente';

  @override
  String get credStatusApproved => 'Aprovado';

  @override
  String get credStatusRejected => 'Recusado';

  @override
  String get credFeePaid => 'Taxa indicada como paga';

  @override
  String get credFeePending => 'Taxa pendente (se aplicável)';

  @override
  String get trainReqLoadFailed => 'Falha ao carregar.';

  @override
  String get trainReqSnackUpdated => 'Pedido actualizado.';

  @override
  String get trainReqUseOrangeBanner =>
      'Use o aviso laranja no topo para vincular a sua instituição.';

  @override
  String get trainReqIntro =>
      'Aprove, designe um instrutor credenciado e associe ao treino realizado quando existir.';

  @override
  String get trainReqKanbanColumnQueue => 'Fila';

  @override
  String get trainReqKanbanColumnQueueHint => 'Pendente · Aprovado';

  @override
  String get trainReqKanbanColumnScheduled => 'Agendado';

  @override
  String get trainReqKanbanColumnScheduledHint => 'Com instrutor designado';

  @override
  String get trainReqKanbanColumnClosed => 'Encerrados';

  @override
  String get trainReqKanbanColumnClosedHint => 'Concluído · Recusado';

  @override
  String get trainReqEmpty => 'Nenhum pedido de treino.';

  @override
  String trainReqReasonLine(Object text) {
    return 'Motivo: $text';
  }

  @override
  String trainReqPriorityLine(Object text) {
    return 'Prioridade: $text';
  }

  @override
  String trainReqParkLine(Object name, Object detail) {
    return 'Parque: $name ($detail)';
  }

  @override
  String trainReqPreferredDates(Object desired, Object limit) {
    return 'Datas preferidas: $desired · limite $limit';
  }

  @override
  String trainReqNotesLine(Object text) {
    return 'Notas: $text';
  }

  @override
  String get trainReqFieldStatus => 'Estado';

  @override
  String get trainReqStatusPending => 'Pendente';

  @override
  String get trainReqStatusApproved => 'Aprovado';

  @override
  String get trainReqStatusScheduled => 'Agendado';

  @override
  String get trainReqStatusRejected => 'Recusado';

  @override
  String get trainReqStatusFulfilled => 'Concluído';

  @override
  String get trainReqFieldAssignedInstructor => 'Instrutor designado';

  @override
  String get trainReqFieldFulfilledTraining => 'Treino realizado';

  @override
  String get trainReqDashNone => '—';

  @override
  String trainReqLinkedTraining(Object title, Object hash) {
    return 'Vinculado: $title · hash $hash';
  }

  @override
  String get trainReqBtnSaveChanges => 'Guardar alterações';

  @override
  String get trainReqBatchCheckboxLabel => 'Seleccionar para agendar em lote';

  @override
  String trainReqBatchToolbarSelected(int count) {
    return '$count seleccionados';
  }

  @override
  String get trainReqBatchToolbarClear => 'Limpar selecção';

  @override
  String get trainReqBatchToolbarSchedule => 'Agendar em lote';

  @override
  String get trainReqBatchDialogTitle => 'Agendar pedidos em lote';

  @override
  String trainReqBatchDialogBody(int count) {
    return 'Defina o instrutor para $count pedido(s) na fila (pendente ou aprovado).';
  }

  @override
  String get trainReqBatchSelectInstructorPlaceholder => 'Escolha o instrutor…';

  @override
  String get trainReqBatchConfirm => 'Agendar';

  @override
  String trainReqBatchSnackDone(int count) {
    return '$count pedido(s) agendado(s).';
  }

  @override
  String get trainReqBatchSnackNoneEligible =>
      'Nenhum pedido elegível na selecção (use pendente ou aprovado na fila).';

  @override
  String get trainReqBatchNoInstructors =>
      'Não há instrutores credenciados — aprove credenciais primeiro.';

  @override
  String get parkSnackPickCatalog => 'Escolha um modelo do catálogo.';

  @override
  String get parkSnackUnitRegisteredPending => 'Unidade registada (pendente).';

  @override
  String get parkBannerLinkInstitutionFirst =>
      'Associe primeiro a sua instituição no banner acima.';

  @override
  String get parkIntro =>
      'Cada unidade replica um modelo do catálogo do fabricante. Estado inicial: pendente; activo quando em uso homologado.';

  @override
  String get parkSearchHint =>
      'Pesquisar nome, modelo, setor ou fabricante (no catálogo)';

  @override
  String get parkFilterByState => 'Filtrar por estado';

  @override
  String get parkFilterChipAll => 'Todos';

  @override
  String get parkFilterChipPending => 'Pendentes';

  @override
  String get parkFilterChipActive => 'Activos';

  @override
  String get parkFilterByCategory => 'Filtrar por categoria';

  @override
  String get parkFilterChipAllCategories => 'Todas';

  @override
  String get parkSectionAddUnit => 'Adicionar unidade';

  @override
  String get parkEmptyCatalog =>
      'Sem modelos no catálogo de fabricantes — ainda não há equipamentos para vincular.';

  @override
  String get parkCatalogDropdownHint => 'Modelo do catálogo';

  @override
  String get parkFieldSectorOptional => 'Setor / local (opcional)';

  @override
  String get parkFieldSectorHintExample => 'Ex.: UCI B, Bloco 3';

  @override
  String get parkBtnRegisterUnit => 'Registar unidade';

  @override
  String parkUnitsCount(Object count) {
    return 'Unidades ($count)';
  }

  @override
  String get parkEmptyPark => 'Nenhuma unidade no parque.';

  @override
  String get parkEquipmentFallbackName => 'Equipamento';

  @override
  String get parkBtnActivate => 'Activar';

  @override
  String get parkStatusPending => 'Pendente';

  @override
  String get parkStatusActive => 'Activo';

  @override
  String get endorsSnackRecorded => 'Endosso registado.';

  @override
  String get endorsEmpty => 'Nenhum pedido de homologação aguarda endosso.';

  @override
  String get endorsIntro =>
      'Confirme que o instrutor está credenciado na sua instituição perante o pedido de homologação junto do fabricante.';

  @override
  String get endorsManufacturerFallback => 'Fabricante';

  @override
  String endorsInstructorLine(Object name) {
    return 'Instrutor: $name';
  }

  @override
  String get endorsBtnEndorse => 'Endossar';

  @override
  String get fluxRevSnackStatusUpdated => 'Estado actualizado.';

  @override
  String get fluxRevEmpty => 'Nenhum fabricante em análise.';

  @override
  String get fluxRevQueueTitle => 'Fila de validação';

  @override
  String get fluxRevIntro =>
      'Aprovar torna o fabricante visível no catálogo para credenciação; recusar ou pedir informações devolve o fluxo ao fabricante.';

  @override
  String fluxRevIdLine(Object id) {
    return 'ID $id';
  }

  @override
  String fluxRevCnpjLine(Object value) {
    return 'CNPJ: $value';
  }

  @override
  String fluxRevSupportLine(Object email) {
    return 'Suporte: $email';
  }

  @override
  String get fluxRevBtnRequestInfo => 'Pedir informações';

  @override
  String get mfgLoadFailedData => 'Falha ao carregar dados.';

  @override
  String get mfgAreaTitle => 'Fabricante';

  @override
  String get mfgNavHome => 'Início';

  @override
  String get mfgNavCompany => 'Empresa';

  @override
  String get mfgNavProducts => 'Produtos';

  @override
  String get mfgNavOperations => 'Operações';

  @override
  String get mfgNavHomologations => 'Homologações';

  @override
  String get mfgNavAnalytics => 'Análises';

  @override
  String get mfgAnalyticsTitle => 'Análises agregadas';

  @override
  String get mfgAnalyticsIntro =>
      'Filtre por instituição, equipamento ligado ao treino ou período de criação dos treinos. Dados agregados, sem identificação individual (LGPD).';

  @override
  String get mfgAnalyticsFilterInstitution => 'Instituição';

  @override
  String get mfgAnalyticsFilterEquipment => 'Equipamento (no treino)';

  @override
  String get mfgAnalyticsDateFrom => 'Treinos criados desde (AAAA-MM-DD)';

  @override
  String get mfgAnalyticsDateTo => 'Treinos criados até (AAAA-MM-DD)';

  @override
  String get mfgAnalyticsApply => 'Aplicar filtros';

  @override
  String get mfgAnalyticsReset => 'Limpar';

  @override
  String get mfgAnalyticsAll => 'Todas/os';

  @override
  String get mfgAnalyticsSectionInstitutions => 'Por instituição';

  @override
  String get mfgAnalyticsSectionEquipment => 'Por equipamento';

  @override
  String get mfgAnalyticsEmpty => 'Sem dados para estes filtros.';

  @override
  String get mfgAnalyticsLoading => 'A carregar…';

  @override
  String mfgAnalyticsBreakdownSubtitle(
    int trainings,
    int enr,
    int done,
    String rate,
    String avg,
  ) {
    return '$trainings treinos · inscr.: $enr · concl.: $done · taxa: $rate · média: $avg';
  }

  @override
  String get mfgAnalyticsSectionMonthlyTrend => 'Tendência mensal (combinada)';

  @override
  String get mfgAnalyticsMonthlyTrendIntro =>
      'Mesmo eixo temporal (AAAA-MM): inscrições por COALESCE(joined_at, created_at) e conclusões por completed_at (UTC). Barras normalizadas ao máximo de cada métrica.';

  @override
  String get mfgAnalyticsMonthlyTrendEmpty =>
      'Sem dados mensais no período filtrado.';

  @override
  String get mfgAnalyticsTrendLegendEnroll => 'Inscrições';

  @override
  String get mfgAnalyticsTrendLegendComplete => 'Concluídas';

  @override
  String mfgHomologRequestedAt(String date) {
    return 'Registado: $date';
  }

  @override
  String get mfgHomologEmpty =>
      'Nenhum pedido de credenciamento neste momento.';

  @override
  String get mfgHomologFilterAll => 'Todos';

  @override
  String get mfgHomologFilterPending => 'Pendentes';

  @override
  String get mfgHomologFilterApproved => 'Aprovados';

  @override
  String get mfgHomologFilterRejected => 'Recusados';

  @override
  String get mfgHomologFilterSuspended => 'Suspensos';

  @override
  String get mfgSnackHomologUpdated => 'Pedido de homologação atualizado.';

  @override
  String get mfgNavGroupSummary => 'Resumo e cadastro';

  @override
  String get mfgNavGroupOffer => 'Oferta e rotina';

  @override
  String get mfgDashSummaryTitle => 'Resumo agregado';

  @override
  String get mfgDashSummaryIntro =>
      'Treinos e inscrições ligados a este fabricante — dados agregados (LGPD).';

  @override
  String get mfgDashMonthlyTrendTitle => 'Evolução recente (mensal)';

  @override
  String get mfgDashMonthlyTrendIntro =>
      'Até os últimos 6 meses com dados: inscrições vs. conclusões (mesma lógica que em Análises).';

  @override
  String get mfgDashOpenAnalytics => 'Abrir análises';

  @override
  String get mfgDashSummaryUnavailableTitle => 'Resumo agregado indisponível';

  @override
  String get mfgDashSummaryUnavailableBody =>
      'Não foi possível carregar o resumo neste momento. Tente novamente ou abra Análises.';

  @override
  String get mfgSnackValidationRequested =>
      'Pedido de validação enviado. A nossa equipa irá analisar.';

  @override
  String get mfgSeasonNewTitle => 'Nova temporada';

  @override
  String get mfgFieldName => 'Nome';

  @override
  String get mfgFieldSeasonStart => 'Início (AAAA-MM-DD)';

  @override
  String get mfgFieldSeasonEnd => 'Fim (AAAA-MM-DD)';

  @override
  String get mfgFieldTargetTrainingsOptional =>
      'Meta treinos encerrados (opcional)';

  @override
  String get mfgBtnCancel => 'Cancelar';

  @override
  String get mfgBtnClose => 'Fechar';

  @override
  String get mfgBtnCreate => 'Criar';

  @override
  String get mfgSeasonCreatedSnack => 'Temporada criada e ranking atualizado.';

  @override
  String get mfgSeasonCreateFailed => 'Não foi possível criar.';

  @override
  String get mfgSeasonRankingTitle => 'Ranking da temporada';

  @override
  String mfgSeasonTargetLine(Object count) {
    return 'Meta: $count treinos encerrados';
  }

  @override
  String get mfgSeasonNoClosedTrainings =>
      'Sem treinos encerrados no período (com este fabricante).';

  @override
  String get mfgLeaderboardLoadFailed => 'Falha ao carregar ranking.';

  @override
  String get mfgSnackRankingRecomputed => 'Ranking recalculado.';

  @override
  String mfgPointsTrainings(Object count) {
    return '$count treinos';
  }

  @override
  String get mfgPrizeNewTitle => 'Novo prémio (registo)';

  @override
  String get mfgFieldTitle => 'Título';

  @override
  String get mfgFieldDescriptionOptional => 'Descrição (opcional)';

  @override
  String get mfgFieldSortOptional => 'Ordem (opcional, menor = primeiro)';

  @override
  String get mfgBtnSave => 'Guardar';

  @override
  String get mfgPrizeSavedSnack => 'Prémio registado.';

  @override
  String get mfgPrizeSaveFailed => 'Não foi possível guardar.';

  @override
  String get mfgPrizeDeleteTitle => 'Remover prémio?';

  @override
  String get mfgPrizeDeleteBody =>
      'O registo será apagado. Isto não afilia pagamentos (MVP).';

  @override
  String get mfgBtnAdd => 'Adicionar';

  @override
  String get mfgBtnRemove => 'Remover';

  @override
  String get mfgSnackRemoved => 'Removido.';

  @override
  String get mfgSnackProfileUpdated => 'Perfil atualizado.';

  @override
  String mfgSnackVersionDraftHint(Object parentId) {
    return 'Preencha o novo modelo e toque em «Adicionar ao catálogo» (origem #$parentId).';
  }

  @override
  String get mfgSnackNameModelRequired => 'Nome e modelo são obrigatórios.';

  @override
  String get mfgSnackEquipmentCreated => 'Equipamento criado.';

  @override
  String get mfgSnackNewVersionRegistered => 'Nova versão registada.';

  @override
  String get mfgSnackFileReadError => 'Não foi possível ler o ficheiro.';

  @override
  String get mfgSnackDocumentUploaded => 'Documento enviado.';

  @override
  String get mfgSnackUploadFailed => 'Falha ao enviar.';

  @override
  String get mfgSnackDocumentRemoved => 'Documento removido.';

  @override
  String mfgSnackFileSaved(Object name) {
    return 'Guardado: $name';
  }

  @override
  String get mfgSnackDownloadFailed => 'Falha ao descarregar.';

  @override
  String get mfgFileFallbackName => 'Ficheiro';

  @override
  String get mfgSnackOfficialTitleRequired =>
      'Informe o título do treinamento oficial.';

  @override
  String get mfgSnackTemplateCreated =>
      'Template criado. Toque em «Editar questionário» na lista abaixo para o conteúdo oficial.';

  @override
  String get mfgSeasonsSectionTitle => 'Temporadas e ranking';

  @override
  String get mfgSeasonsIntro =>
      'Pontos = treinos encerrados (estado «finished») ligados a este fabricante, no período da temporada. Atualização diária automática ou manual.';

  @override
  String get mfgSeasonsEmpty =>
      'Nenhuma temporada — crie uma para acompanhar instrutores por semestre ou ciclo.';

  @override
  String mfgSeasonMetaSuffix(Object count) {
    return ' · meta $count';
  }

  @override
  String get mfgTooltipViewLeaderboard => 'Ver ranking';

  @override
  String get mfgTooltipRecompute => 'Recalcular';

  @override
  String get mfgPrizesSectionTitle => 'Prémios (registo)';

  @override
  String get mfgPrizesIntro =>
      'Descrição informativa para campanhas ou reconhecimentos — sem pagamento integrado no MVP.';

  @override
  String get mfgPrizesEmpty => 'Nenhum prémio registado.';

  @override
  String get mfgDocumentsSectionTitle => 'Documentos para validação';

  @override
  String get mfgDocumentsIntro =>
      'PDF ou imagem até 12 MB. O servidor usa o disco configurado (local ou S3 via FILESYSTEM_DISK); envie manuais ou anexos para homologação.';

  @override
  String get mfgOpsSearchHint =>
      'Pesquisar épocas, prémios e documentos enviados';

  @override
  String get mfgOpsServerFilterHint =>
      'Filtro no servidor; os resultados actualizam pouco depois de parar de escrever.';

  @override
  String get mfgOpsSublistNoMatch => 'Sem resultados neste bloco.';

  @override
  String get mfgOpsLoadMore => 'Carregar mais';

  @override
  String get mfgDocKindOptional => 'Tipo (opcional)';

  @override
  String get mfgDocKindHint => 'Ex.: manual, certificado, ficha técnica';

  @override
  String get mfgDocNotesOptional => 'Notas (opcional)';

  @override
  String get mfgBtnSendFile => 'Enviar ficheiro';

  @override
  String get mfgDocumentsEmpty => 'Nenhum documento enviado.';

  @override
  String get mfgTooltipDownload => 'Descarregar';

  @override
  String get mfgOfficialTrainingTitle => 'Treinamentos oficiais (templates)';

  @override
  String get mfgOfficialTrainingIntro =>
      'Templates sem instituição; instrutores homologados instanciam para o hospital.';

  @override
  String get mfgTemplateTitleLabel => 'Título do template';

  @override
  String get mfgTemplateTitleHint => 'Ex.: Operação básica do ventilador X';

  @override
  String get mfgBtnCreateTemplateDraft => 'Criar template (rascunho)';

  @override
  String get mfgYourTemplates => 'Seus templates';

  @override
  String get mfgTemplatesEmpty => 'Nenhum template ainda. Crie um acima.';

  @override
  String get mfgTplSearchHint => 'Pesquisar título do template';

  @override
  String get mfgTplFilterStatusLabel => 'Estado do template';

  @override
  String get mfgTplSortLabel => 'Ordenar lista';

  @override
  String get mfgTplSortUpdated => 'Actualizados recentemente';

  @override
  String get mfgTplSortTitleAsc => 'Título (A–Z)';

  @override
  String get mfgTplSortTitleDesc => 'Título (Z–A)';

  @override
  String get mfgTplSortStatus => 'Por estado';

  @override
  String mfgTplRowUpdatedAt(String date) {
    return 'Actualizado: $date';
  }

  @override
  String mfgTplListResultCount(Object count) {
    return '$count template(s) listado(s) (até 80).';
  }

  @override
  String get mfgTplClearFilters => 'Limpar filtros';

  @override
  String get mfgTplNoMatches =>
      'Nenhum template corresponde aos filtros actuais.';

  @override
  String get mfgTrainingFallbackTitle => 'Treino';

  @override
  String get mfgBtnEditQuestionnaire => 'Editar questionário';

  @override
  String get mfgCompanySectionTitle => 'Empresa';

  @override
  String get mfgFieldSupportEmail => 'E-mail de suporte';

  @override
  String get mfgLabelCnpj => 'CNPJ';

  @override
  String get mfgBtnSaveProfile => 'Guardar perfil';

  @override
  String get mfgCatalogSectionTitle => 'Catálogo (homologações)';

  @override
  String get mfgCatalogIntro =>
      'Equipamentos aqui ficam sem instituição — visíveis para montagem de treinos. Com versões derivadas, o registo original deixa de ser editável.';

  @override
  String mfgNewVersionFromRecord(Object id) {
    return 'Nova versão a partir do registo #$id';
  }

  @override
  String get mfgFieldEquipmentName => 'Nome do equipamento';

  @override
  String get mfgFieldModel => 'Modelo';

  @override
  String get mfgFieldSectorOptionalCatalog => 'Setor (opcional)';

  @override
  String get mfgCategoryOptionalLabel => 'Categoria (opcional)';

  @override
  String get mfgBtnAddToCatalog => 'Adicionar ao catálogo';

  @override
  String get mfgFilterListLabel => 'Filtrar lista';

  @override
  String get mfgEquipmentEmpty => 'Nenhum equipamento ainda.';

  @override
  String mfgEquipmentDerivedFrom(Object parentId, Object model) {
    return 'Versão derivada de #$parentId · $model';
  }

  @override
  String get mfgBtnNewVersion => 'Nova versão';

  @override
  String get mfgDashQuickCatalogTitle => 'Equipamentos no catálogo';

  @override
  String get mfgDashQuickCatalogBody =>
      'Registe modelo, documentação e pré-definições de treino num fluxo em dois passos.';

  @override
  String get mfgDashNewEquipment => 'Novo equipamento';

  @override
  String get mfgEquipWizardTitle => 'Novo equipamento';

  @override
  String get mfgEquipWizardEditTitle => 'Editar equipamento';

  @override
  String get mfgEquipWizardSaveChanges => 'Guardar alterações';

  @override
  String get mfgBtnEditEquipment => 'Editar';

  @override
  String get mfgEquipWizardStep1 => 'Identificação e ficha';

  @override
  String get mfgEquipWizardStep2 => 'Treino e anexos';

  @override
  String get mfgEquipWizardNext => 'Seguinte';

  @override
  String get mfgEquipWizardBack => 'Voltar';

  @override
  String get mfgEquipWizardSubmit => 'Guardar';

  @override
  String get mfgEquipErrInvalidInteger =>
      'Use números inteiros nos campos numéricos opcionais.';

  @override
  String get mfgEquipErrHoursRange => 'Horas de treino: entre 1 e 999.';

  @override
  String get mfgEquipErrPassRange => 'Nota mínima (%): entre 40 e 100.';

  @override
  String get mfgEquipErrCertMonthsRange =>
      'Validade do certificado (meses): entre 1 e 240.';

  @override
  String get mfgEquipErrReassessRange => 'Reavaliação (dias): entre 1 e 365.';

  @override
  String get mfgEquipErrQuantityRange =>
      'Quantidade: pelo menos 1 se preenchida.';

  @override
  String get mfgEquipFieldFirmware => 'Firmware (versão)';

  @override
  String get mfgEquipFieldSerial => 'Número de série';

  @override
  String get mfgEquipCategoryRequired => 'Categoria *';

  @override
  String get mfgEquipSnackCategoryRequired =>
      'Escolha uma categoria para o equipamento raiz.';

  @override
  String get mfgEquipSpecsTitle => 'Atributos técnicos (opcional)';

  @override
  String get mfgEquipSpecLabel => 'Nome';

  @override
  String get mfgEquipSpecValue => 'Valor';

  @override
  String get mfgEquipAddSpecRow => 'Adicionar linha';

  @override
  String get mfgEquipFieldIntroVideoUrl => 'URL vídeo de introdução (opcional)';

  @override
  String get mfgEquipDefaultsTitle => 'Pré-definições de treino (opcional)';

  @override
  String get mfgEquipDefaultsRangeHint =>
      'Se preencher: horas 1–999, nota 40–100 %, certificado 1–240 meses, reavaliação 1–365 dias, quantidade ≥ 1.';

  @override
  String get mfgEquipHelperHours => 'Opcional · inteiro · 1–999';

  @override
  String get mfgEquipHelperPass => 'Opcional · inteiro · 40–100';

  @override
  String get mfgEquipHelperCertMonths => 'Opcional · inteiro · 1–240';

  @override
  String get mfgEquipHelperReassess => 'Opcional · inteiro · 1–365';

  @override
  String get mfgEquipHelperQuantity => 'Opcional · inteiro · ≥ 1';

  @override
  String get mfgEquipDefaultTrainingHours => 'Horas de treino';

  @override
  String get mfgEquipDefaultPassingScore => 'Nota mínima (%)';

  @override
  String get mfgEquipDefaultCertMonths => 'Validade certificado (meses)';

  @override
  String get mfgEquipDefaultReassessmentDays => 'Reavaliação (dias)';

  @override
  String get mfgEquipFieldQuantity => 'Quantidade';

  @override
  String get mfgEquipFieldStatus => 'Estado';

  @override
  String get mfgEquipStatusActive => 'Ativo';

  @override
  String get mfgEquipStatusInactive => 'Inativo';

  @override
  String get mfgEquipAttachmentsTitle => 'Ficheiros (opcional)';

  @override
  String get mfgEquipAttachImage => 'Imagem do equipamento';

  @override
  String get mfgEquipAttachManualOp => 'Manual do operador (PDF)';

  @override
  String get mfgEquipAttachManualMaint => 'Manual de manutenção (PDF)';

  @override
  String get mfgEquipAttachDatasheet => 'Ficha técnica (PDF)';

  @override
  String get mfgEquipAttachIntroVideo => 'Vídeo de introdução (MP4)';

  @override
  String get mfgEquipPickFile => 'Escolher';

  @override
  String get mfgEquipClearFile => 'Limpar';

  @override
  String get mfgEquipSearchHint => 'Pesquisar nome, modelo ou série';

  @override
  String get mfgEquipFilterStatusLabel => 'Estado na lista';

  @override
  String get mfgEquipStatusFilterAll => 'Todos';

  @override
  String mfgEquipTemplatesCount(Object count) {
    return '$count template(s) oficial(is)';
  }

  @override
  String get mfgEquipSortLabel => 'Ordenar lista';

  @override
  String get mfgEquipSortName => 'Nome (A–Z)';

  @override
  String get mfgEquipSortUpdated => 'Actualizados recentemente';

  @override
  String get mfgEquipSortTemplates => 'Mais templates oficiais';

  @override
  String mfgEquipListResultCount(Object count) {
    return '$count modelo(s) listado(s) (até 200).';
  }

  @override
  String get mfgEquipClearFilters => 'Limpar filtros';

  @override
  String get mfgEquipSnackPartialUpload =>
      'Equipamento criado; alguns anexos falharam.';

  @override
  String get mfgValidationTitle => 'Credenciação do fabricante';

  @override
  String mfgValidationStateLine(Object status) {
    return 'Estado: $status';
  }

  @override
  String get mfgFlowStepCompany => 'Dados da empresa';

  @override
  String get mfgFlowStepFluxxoReview => 'Análise da plataforma';

  @override
  String get mfgFlowStepHomologation => 'Homologação';

  @override
  String get mfgValStatusPendingInfo => 'Informações pendentes';

  @override
  String get mfgValStatusPendingValidation => 'Em análise pela equipa';

  @override
  String get mfgValStatusActive => 'Ativo na rede credenciada';

  @override
  String get mfgValStatusRejected => 'Validação recusada';

  @override
  String get mfgValHelpPendingInfo =>
      'Complete os dados da empresa e submeta para validação. Pode anexar documentação de suporte em «Operações» → Documentos.';

  @override
  String get mfgValHelpPendingValidation =>
      'O seu pedido está na fila de análise Fluxxo. Prazo estimado: 24 a 48 horas úteis. Receberá um e-mail quando for aprovado.';

  @override
  String get mfgValHelpActive =>
      'O fabricante está homologado na rede. Instrutores podem solicitar credenciação a este fabricante e usar os templates oficiais no catálogo.';

  @override
  String get mfgValHelpRejected =>
      'Ajuste os dados ou documentação indicados pela equipa e volte a submeter.';

  @override
  String get mfgValHelpDefault =>
      'Estado de credenciação do fabricante na plataforma.';

  @override
  String get mfgBtnSubmitForReview => 'Submeter para análise';

  @override
  String get mfgBtnResubmitForReview => 'Voltar a submeter para análise';

  @override
  String get trnSnackSectorRequired => 'Informe o setor.';

  @override
  String get trnSnackCodeRequired => 'Informe o código.';

  @override
  String get trnSnackSessionPaused =>
      'A sessão está em pausa. Aguarde o instrutor retomar.';

  @override
  String get trnSnackPickOption => 'Selecione uma opção.';

  @override
  String get trnSnackLgpdCheckbox =>
      'Marque a caixa para confirmar que leu e concorda.';

  @override
  String get trnSnackJsonCopied =>
      'Dados copiados para a área de transferência (JSON).';

  @override
  String get trnSnackCancelled => 'Cancelado.';

  @override
  String get trnSnackFormOpenFailed => 'Não foi possível abrir o formulário.';

  @override
  String trnSnackFollowUpAvailableFrom(Object due) {
    return 'Disponível a partir de $due.';
  }

  @override
  String get trnSnackFollowUpNotYet => 'Ainda não pode responder.';

  @override
  String get trnSnackResponsesSaved => 'Respostas registadas.';

  @override
  String get trnSnackCertPdfDownloaded => 'PDF do certificado descarregado.';

  @override
  String get trnSnackCertPdfFailed => 'Não foi possível descarregar o PDF.';

  @override
  String get trnSnackPickInstitution =>
      'Selecione a instituição no pré-registro.';

  @override
  String get trnSnackPickReason => 'Escolha o motivo do pedido.';

  @override
  String get trnSnackRequestSent => 'Pedido enviado à instituição.';

  @override
  String get trnDeleteAccountTitle => 'Excluir conta';

  @override
  String get trnDeleteAccountBodyGoogle =>
      'Esta ação anonimiza a sua conta de forma irreversível (Art. 18 LGPD). Confirme com EXCLUIR e autentique novamente com Google.';

  @override
  String get trnDeleteAccountBodyPassword =>
      'Esta ação anonimiza a sua conta de forma irreversível (Art. 18 LGPD). Digite EXCLUIR em maiúsculas e a sua senha.';

  @override
  String get trnFieldPassword => 'Senha';

  @override
  String get trnFieldConfirmDelete => 'Confirmar (digite EXCLUIR)';

  @override
  String get trnBtnConfirm => 'Confirmar';

  @override
  String get trnApiOk => 'API ok';

  @override
  String get trnApiOffline => 'Sem API';

  @override
  String get trnTooltipPrivacy => 'Privacidade';

  @override
  String get trnMenuExportJson => 'Exportar meus dados (JSON)';

  @override
  String get trnMenuDeleteAccount => 'Excluir minha conta';

  @override
  String get trnTooltipSignOut => 'Sair';

  @override
  String get trnPrivacyTitle => 'Privacidade e dados';

  @override
  String get trnLgpdIntro =>
      'Antes de usar o treinamento, precisamos do seu consentimento explícito (LGPD — Lei 13.709/2018):';

  @override
  String get trnLgpdBullets =>
      '• Finalidade: identificação em treinamentos, certificados e relatórios agregados da instituição.\n• Compartilhamento: dados individuais apenas com o instrutor durante a sessão; à instituição, de forma agregada.\n• Retenção: até 5 anos após o último treinamento para auditoria, salvo exclusão ou anonimização a seu pedido.\n• Direitos: acesso, correção, portabilidade e exclusão pelo menu Privacidade (ícone no topo).\n• Google: ao usar login Google, dados também são tratados segundo a política do Google.';

  @override
  String get trnLgpdCheckboxTitle =>
      'Li e concordo com o tratamento dos meus dados pessoais conforme a Política de Privacidade do App²cation.';

  @override
  String get trnLgpdAfterConsentHint =>
      'Depois de continuar, pode exportar os seus dados ou pedir exclusão da conta a qualquer momento no menu Privacidade (ícone de escudo) no cabeçalho.';

  @override
  String get trnBtnContinue => 'Continuar';

  @override
  String get trnPreregTitle => 'Pré-registro';

  @override
  String get trnPreregSubtitle => 'Dados reais gravados na sua conta.';

  @override
  String get trnFieldInstitutionOptional => 'Instituição (opcional)';

  @override
  String get trnInstitutionNone => 'Sem instituição';

  @override
  String get trnProfileInstitutionHint =>
      'Vincular um hospital desbloqueia o parque de equipamentos da instituição para pedidos de treino e pode ser exigido pela política da sua unidade.';

  @override
  String get trnFieldSectorTeam => 'Setor / equipe *';

  @override
  String get trnFieldEquipmentContext => 'Equipamento / contexto';

  @override
  String get trnFieldSessionAtOptional => 'Data e hora da sessão (opcional)';

  @override
  String get trnHintDatetime => 'AAAA-MM-DD HH:MM';

  @override
  String get trnBtnSaveContinue => 'Salvar e continuar';

  @override
  String get trnCertificatesTitle => 'Certificados';

  @override
  String get trnCertificatesEmpty =>
      'Nenhum certificado ainda — conclua um treinamento com nota ≥ mínima.';

  @override
  String trnCertScoreValid(Object score, Object expires) {
    return 'Nota $score · válido até $expires';
  }

  @override
  String get trnFollowUpsTitle => 'Reavaliações pós-treino';

  @override
  String get trnFollowUpsIntro =>
      'Questionários curtos (ex.: 10, 15 e 30 dias após a conclusão), conforme configuração do treino.';

  @override
  String get trnFollowUpsEmpty => 'Nenhuma reavaliação agendada.';

  @override
  String trnFollowUpListSubtitle(Object days, Object status, Object due) {
    return 'Dia +$days · $status · previsto $due';
  }

  @override
  String get trnTrainingRequestTitle => 'Pedido de treinamento (instituição)';

  @override
  String get trnTrainingRequestIntro =>
      'Motivo padronizado, prioridade e datas preferidas para o pedido.';

  @override
  String get trnLoadingOptions => 'A carregar opções…';

  @override
  String get trnFieldReason => 'Motivo';

  @override
  String get trnFieldPriority => 'Prioridade';

  @override
  String get trnFieldParkUnitOptional => 'Unidade do parque (opcional)';

  @override
  String get trnParkUnitHelper => 'Lista da instituição do seu pré-registro.';

  @override
  String get trnParkEmptyHint =>
      'Sem unidades no parque ou complete o pré-registro com instituição para carregar o parque.';

  @override
  String get trnFieldPreferredDate => 'Data preferida (opcional)';

  @override
  String get trnHintDate => 'AAAA-MM-DD';

  @override
  String get trnFieldLatestAcceptable => 'Última data aceitável (opcional)';

  @override
  String get trnFieldNotesOptional => 'Notas (opcional)';

  @override
  String get trnNotesHint => 'Detalhe local, turno, contacto…';

  @override
  String get trnBtnSendRequest => 'Enviar pedido';

  @override
  String get trnMyRequests => 'Meus pedidos';

  @override
  String get trnJoinTitle => 'Entrar no treinamento';

  @override
  String get trnJoinIntro => 'Use o código fornecido pelo instrutor.';

  @override
  String get trnJoinIntroDetail =>
      'O instrutor partilha o código ou hash depois de ser convidado (e-mail, aplicação ou presencial). Pode colar a partir de uma mensagem; espaços são ignorados e maiúsculas/minúsculas não importam.';

  @override
  String get trnJoinAccessCodeHint => 'Cole o código enviado pelo instrutor';

  @override
  String get trnJoinHashKeepTyping =>
      'A maioria dos códigos tem 12 caracteres — continue a escrever ou cole o código completo.';

  @override
  String get trnJoinHashFormatOk =>
      'O formato parece válido. Toque em confirmar para entrar.';

  @override
  String get trnFieldAccessCode => 'Código de acesso';

  @override
  String get trnBtnConfirmJoin => 'Confirmar entrada';

  @override
  String get trnJoinOfflineHint =>
      'A aplicação não consegue contactar o servidor. Verifique a ligação antes de confirmar a entrada.';

  @override
  String get trnWaitingRoomTitle => 'Sala de espera';

  @override
  String get trnWaitingRoomBody =>
      'Assim que o instrutor iniciar, o questionário abre automaticamente.';

  @override
  String get trnWaitingHeroTitle => 'Aguardando início do treinamento';

  @override
  String get trnWaitingHeroBody =>
      'O instrutor iniciará a sessão em breve. Mantenha esta janela aberta para entrar automaticamente na sala virtual.';

  @override
  String get trnWaitingOfflineHint =>
      'Não há ligação à API. Quando a rede voltar, puxe para actualizar ou toque em «Actualizar estado» para sincronizar assim que o instrutor iniciar.';

  @override
  String get trnWaitingStatusChip => 'Status: sala de espera ativa';

  @override
  String get trnWaitingTestConnection => 'Testar conexão e periféricos';

  @override
  String get trnWaitingCheckNow => 'Actualizar estado';

  @override
  String get trnWaitingPingOk => 'Ligação ao servidor OK.';

  @override
  String get trnWaitingPingFail => 'Não foi possível contactar o servidor.';

  @override
  String get trnWaitingPrivacyNote =>
      'Câmara e microfone permanecem desativados por defeito nesta versão.';

  @override
  String get trnHeaderProfileStep => 'Perfil e instituição';

  @override
  String get trnHeaderWaitingInstructor => 'Aguardando instrutor';

  @override
  String get trnHeaderRealtimeActive => 'Tempo real: ativo';

  @override
  String get trnQuestionSidebarNavTitle => 'Navegação';

  @override
  String get trnEmptyRecoverySync =>
      'A sincronizar repescagem ou a concluir o treino…';

  @override
  String get trnEmptyNoQuestions => 'Nenhuma questão disponível.';

  @override
  String get trnPausedSessionBanner =>
      'Sessão em pausa. Não é possível responder até o instrutor retomar.';

  @override
  String get trnRecoveryBanner =>
      'Repescagem: apenas as questões que o instrutor libertou para nova tentativa.';

  @override
  String get trnProgressLabel => 'PROGRESSO';

  @override
  String trnQuestionProgress(Object current, Object total) {
    return 'Questão $current de $total';
  }

  @override
  String get trnBtnConfirmAnswer => 'Confirmar resposta';

  @override
  String get trnBtnContinueAfterFeedback => 'Continuar';

  @override
  String get trnAnswerFeedbackCorrect => 'Resposta correta.';

  @override
  String get trnAnswerFeedbackIncorrect => 'Resposta incorreta.';

  @override
  String trnAnswerCorrectWas(Object label) {
    return 'Resposta certa: $label';
  }

  @override
  String get trnBtnSubmitResponses => 'Enviar respostas';

  @override
  String get trnOptionalHint => 'Opcional';

  @override
  String get trnResultTitle => 'Treinamento concluído';

  @override
  String get trnScoreLabel => 'Nota (0–10)';

  @override
  String get trnResultApprovedBanner =>
      'Aprovado — nota igual ou superior a 7,0.';

  @override
  String get trnResultInsufficientBanner =>
      'Nota abaixo de 7,0. Em caso de dúvida, fale com o instrutor.';

  @override
  String get trnResultRecoveryNote =>
      'Está em recuperação: conclua as questões indicadas pelo instrutor.';

  @override
  String trnResultInstitution(Object name) {
    return 'Instituição: $name';
  }

  @override
  String get trnResultRefresh => 'Actualizar estado';

  @override
  String get trnResultCertificateHint =>
      'Se o instrutor acabou de encerrar o treino, actualize — o certificado pode demorar alguns segundos a aparecer.';

  @override
  String get trnResultCertificateDownload => 'Certificado (PDF)';

  @override
  String get trnResultFollowUpIntro =>
      'Quando a data prevista abrir, toque em Responder para preencher o breve questionário.';

  @override
  String get trnResultOfflineHint =>
      'Sem ligação ao servidor. Pode actualizar quando a rede voltar; o certificado (PDF) e o questionário de seguimento só funcionam online.';

  @override
  String get trnBtnJoinAnother => 'Entrar em outro treinamento';

  @override
  String get trnFollowUpDialogTitle => 'Reavaliação pós-treino';

  @override
  String get trnTrainingDefaultTitle => 'Treinamento';

  @override
  String trnRequestListPark(Object detail) {
    return 'Parque: $detail';
  }

  @override
  String trnRequestListPref(Object date) {
    return 'pref. $date';
  }

  @override
  String trnRequestListLimit(Object date) {
    return 'limite $date';
  }

  @override
  String get trnFollowUpRespond => 'Responder';

  @override
  String get trnTooltipCertPdf => 'Descarregar PDF';

  @override
  String get mfgTplIntro =>
      'Blocos e perguntas seguem o mesmo formato dos treinos operacionais. Os instrutores homologados clonam este conteúdo.';

  @override
  String get mfgTplSectionQuestions => 'Perguntas';

  @override
  String get mfgTplBtnAddQuestion => 'Pergunta';

  @override
  String get mfgTplSnackSaved => 'Questionário guardado.';

  @override
  String get mfgTplErrNeedCorrect =>
      'Cada pergunta precisa de uma opção correta.';

  @override
  String get mfgTplErrMinQuestions =>
      'Adicione pelo menos uma pergunta com 2+ opções.';

  @override
  String get mfgTplErrQuestionNeedTwoOptions =>
      'Cada pergunta com enunciado precisa de pelo menos duas opções preenchidas.';

  @override
  String get mfgTplErrCorrectMustHaveLabel =>
      'A opção marcada como correta tem de ter texto.';

  @override
  String get mfgTplBtnAddOption => 'Opção';

  @override
  String get mfgTplRemoveOptionTooltip => 'Remover opção';

  @override
  String get mfgTplMaxOptionsSnack => 'No máximo 12 opções por pergunta.';

  @override
  String get mfgTplOptionsCountHint =>
      '2–12 opções; linhas vazias são ignoradas ao guardar.';

  @override
  String mfgTplQuestionNumber(Object n) {
    return 'Pergunta $n';
  }

  @override
  String get mfgTplFieldPrompt => 'Enunciado';

  @override
  String get mfgTplOptionsHint => 'Opções (marque a correta)';

  @override
  String mfgTplOptionNumber(Object n) {
    return 'Opção $n';
  }

  @override
  String get mfgTplBtnSaveApi => 'Guardar questionário na API';

  @override
  String get mfgTplOfficialBlockTitle => 'Conteúdo oficial';

  @override
  String get mfgTplReloadTooltip => 'Recarregar do servidor';

  @override
  String get mfgTplRefreshHint =>
      'Puxe para baixo para recarregar do servidor. Alterações não guardadas no formulário serão substituídas.';

  @override
  String get mfgTplMoveUpTooltip => 'Subir pergunta';

  @override
  String get mfgTplMoveDownTooltip => 'Descer pergunta';

  @override
  String get mfgTplDiscardTitle => 'Descartar alterações?';

  @override
  String get mfgTplDiscardBody =>
      'Tem edições não guardadas. Sair sem guardar?';

  @override
  String get mfgTplKeepEditing => 'Continuar a editar';

  @override
  String get mfgTplDiscardLeave => 'Sair sem guardar';

  @override
  String get mfgTplSectionBlocks => 'Secções do questionário';

  @override
  String get mfgTplFieldBlockTitle => 'Título da secção';

  @override
  String get mfgTplBtnAddBlock => 'Adicionar secção';

  @override
  String get mfgTplRemoveBlockTooltip =>
      'Remover secção e unir perguntas à secção acima';

  @override
  String mfgTplBlockDefaultTitle(int n) {
    return 'Secção $n';
  }

  @override
  String get mfgTplViewEdit => 'Editar';

  @override
  String get mfgTplViewPreview => 'Pré-visualizar';

  @override
  String get mfgTplPreviewBanner =>
      'Pré-visualização ao estilo treinando: sem respostas gravadas e sem destacar a opção correcta.';

  @override
  String get mfgTplPreviewEmpty =>
      'Nenhuma pergunta com enunciado para mostrar. Volte a Editar e preencha pelo menos um enunciado.';

  @override
  String get mfgTplMoveBlockUpTooltip => 'Subir secção';

  @override
  String get mfgTplMoveBlockDownTooltip => 'Descer secção';

  @override
  String get fluxPanelTraineeTitle => 'Fluxo do treinando';

  @override
  String get fluxPanelTraineeSubtitle =>
      'Jornada alinhada à especificação: pré-registro → ingresso → LGPD → sessão em tempo real → resultado.';

  @override
  String get fluxPanelTraineeS1Label => 'Perfil e contexto clínico';

  @override
  String get fluxPanelTraineeS1Detail =>
      'Setor, equipamento e instituição quando aplicável.';

  @override
  String get fluxPanelTraineeS2Label => 'Ingresso na sessão';

  @override
  String get fluxPanelTraineeS2Detail =>
      'Código/hash fornecido pelo instrutor ou instituição.';

  @override
  String get fluxPanelTraineeS3Label => 'Consentimento LGPD';

  @override
  String get fluxPanelTraineeS3Detail =>
      'Obrigatório antes de responder ao questionário.';

  @override
  String get fluxPanelTraineeS4Label => 'Sala de espera e sessão ao vivo';

  @override
  String get fluxPanelTraineeS4Detail =>
      'Aguarda o instrutor iniciar; blocos libertados em sequência.';

  @override
  String get fluxPanelTraineeS5Label => 'Respostas e resultado';

  @override
  String get fluxPanelTraineeS5Detail =>
      'Correção imediata; aprovação conforme regra do treino (ex.: ≥70%).';

  @override
  String get fluxPanelInstructorTitle => 'Fluxo do Application (instrutor)';

  @override
  String get fluxPanelInstructorSubtitle =>
      'Credenciamento duplo (instituição + fabricante quando aplicável), criação de sessão e comando em tempo real.';

  @override
  String get fluxPanelInstructorS1Label => 'Credenciamento';

  @override
  String get fluxPanelInstructorS1Detail =>
      'Instituição e catálogo no separador Credenciamento.';

  @override
  String get fluxPanelInstructorS2Label => 'Criar treinamento e questionário';

  @override
  String get fluxPanelInstructorS2Detail =>
      'Treinos, blocos e perguntas alinhados ao equipamento.';

  @override
  String get fluxPanelInstructorS3Label => 'Sala de comando';

  @override
  String get fluxPanelInstructorS3Detail =>
      'Iniciar sessão, libertar blocos, repescagem e encerramento.';

  @override
  String get fluxPanelInstructorS4Label => 'Participantes e acompanhamento';

  @override
  String get fluxPanelInstructorS4Detail =>
      'Lista de inscritos e progresso durante a sessão.';

  @override
  String get fluxPanelInstitutionTitle => 'Fluxo da instituição';

  @override
  String get fluxPanelInstitutionSubtitle =>
      'Gestão de parque, vínculos com instrutores e visão dos treinos na organização.';

  @override
  String get fluxPanelInstitutionS1Label => 'Cadastro e instituições';

  @override
  String get fluxPanelInstitutionS1Detail =>
      'Manter dados da instituição e criar vínculos necessários.';

  @override
  String get fluxPanelInstitutionS2Label => 'Parque tecnológico';

  @override
  String get fluxPanelInstitutionS2Detail =>
      'Declarar equipamentos em uso (evolução contínua no produto).';

  @override
  String get fluxPanelInstitutionS3Label => 'Instrutores na instituição';

  @override
  String get fluxPanelInstitutionS3Detail =>
      'Coordenar quem ministra treinos nos seus espaços.';

  @override
  String get fluxPanelInstitutionS4Label => 'Indicadores agregados';

  @override
  String get fluxPanelInstitutionS4Detail =>
      'Por setor, em conformidade com LGPD (sem identificar indivíduos).';

  @override
  String get fluxPanelManufacturerTitle => 'Fluxo do fabricante';

  @override
  String get fluxPanelManufacturerSubtitle =>
      'Dono do conhecimento técnico: catálogo, conteúdo oficial e rede de instrutores homologados.';

  @override
  String get fluxPanelManufacturerS1Label => 'Perfil da empresa';

  @override
  String get fluxPanelManufacturerS1Detail =>
      'Dados corporativos e contacto de suporte.';

  @override
  String get fluxPanelManufacturerS2Label => 'Catálogo de equipamentos';

  @override
  String get fluxPanelManufacturerS2Detail =>
      'Modelos homologados para treinos e instituições.';

  @override
  String get fluxPanelManufacturerS3Label => 'Banco de treinamentos oficiais';

  @override
  String get fluxPanelManufacturerS3Detail =>
      'Questionários padronizados por equipamento.';

  @override
  String get fluxPanelManufacturerS4Label => 'Homologação de instrutores';

  @override
  String get fluxPanelManufacturerS4Detail =>
      'Taxa e validação da rede Application.';

  @override
  String get fluxPanelManufacturerS5Label => 'Analytics e gamificação';

  @override
  String get fluxPanelManufacturerS5Detail => 'Desempenho agregado e rankings.';

  @override
  String get fluxPanelWeeklyTitle => 'Resumo semanal por e-mail';

  @override
  String get fluxPanelWeeklySubtitle =>
      'Indicadores agregados (LGPD), segundas de manhã. Pode desativar aqui.';

  @override
  String get fluxPanelPrefSaveFailed =>
      'Não foi possível guardar a preferência.';

  @override
  String get fluxPanelRoadmapBadge => 'roadmap';

  @override
  String errApiNetworkUnreachable(Object detail) {
    return 'Sem ligação ao servidor. Verifique a rede e a URL da API. ($detail)';
  }

  @override
  String errApiInvalidHttpBody(Object code) {
    return 'Resposta inválida do servidor (HTTP $code).';
  }

  @override
  String get errApiResponseNotList => 'Resposta não é uma lista.';

  @override
  String get errApiOperationIncomplete =>
      'Não foi possível concluir a operação.';

  @override
  String get errApiUploadMissingFileSource =>
      'Escolha um ficheiro ou indique os dados do ficheiro para enviar.';

  @override
  String get errAuthInvalidLoginResponse => 'Resposta de login inválida.';

  @override
  String get errAuthInvalidRegisterResponse => 'Resposta de cadastro inválida.';

  @override
  String get errAuthGoogleCancelled => 'Login Google cancelado.';

  @override
  String get errAuthInvalidGoogleLoginResponse =>
      'Resposta de login Google inválida.';

  @override
  String get errGoogleNoIdToken =>
      'Google não devolveu id_token. Verifique o Client ID Web e as APIs no Google Cloud.';

  @override
  String errGoogleSignInFailed(Object detail) {
    return 'Falha no login Google: $detail';
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
  String get trnCertCodeFallback => 'certificado';

  @override
  String trnCertDownloadFilename(Object code) {
    return 'certificado-$code';
  }

  @override
  String dashExportFileInstitutionCsv(Object stamp) {
    return 'appcation-instituicao-$stamp.csv';
  }

  @override
  String dashExportFileInstitutionPdf(Object stamp) {
    return 'appcation-instituicao-$stamp.pdf';
  }

  @override
  String dashExportFileManufacturerCsv(Object stamp) {
    return 'appcation-fabricante-$stamp.csv';
  }

  @override
  String dashExportFileManufacturerPdf(Object stamp) {
    return 'appcation-fabricante-$stamp.pdf';
  }

  @override
  String get utilDownloadWebOnly =>
      'O download de ficheiros só está disponível na versão Web.';

  @override
  String get loginIamManufacturer => 'Sou fabricante';

  @override
  String get loginIamInstitution => 'Sou instituição';

  @override
  String get loginIamInstructorLink => 'Sou instrutor (Application)';

  @override
  String get loginInstitutionFootnote =>
      'Gestores acedem com credenciais criadas pela instituição ou fabricante. Para novo registo como equipa clínica, utilize «Começar agora» como instrutor e peça vínculo ao hospital.';

  @override
  String get mfgOnboardTitle => 'Cadastro de fabricante';

  @override
  String mfgOnboardStepCounter(int step, int total) {
    return 'Passo $step de $total';
  }

  @override
  String get mfgOnboardCorporateSection => 'Dados corporativos';

  @override
  String get mfgFieldLegalName => 'Razão social';

  @override
  String get mfgFieldTradeName => 'Nome fantasia';

  @override
  String get mfgFieldStateRegistration => 'Inscrição estadual';

  @override
  String get mfgFieldWebsite => 'Site institucional';

  @override
  String get mfgFieldCommercialPhone => 'Telefone comercial';

  @override
  String get mfgAddressSection => 'Endereço';

  @override
  String get mfgFieldCep => 'CEP';

  @override
  String get mfgCepLookup => 'Buscar CEP';

  @override
  String get mfgFieldStreet => 'Logradouro';

  @override
  String get mfgFieldNeighborhood => 'Bairro';

  @override
  String get mfgFieldCity => 'Cidade';

  @override
  String get mfgFieldState => 'UF';

  @override
  String get mfgOnboardLegalRepSection => 'Representante legal';

  @override
  String get mfgFieldLegalRepName => 'Nome completo';

  @override
  String get mfgFieldLegalRepCpf => 'CPF';

  @override
  String get mfgFieldLegalRepRole => 'Cargo';

  @override
  String get mfgFieldLegalRepPhone => 'Telefone direto';

  @override
  String get mfgOnboardDocsSection => 'Documentos para validação';

  @override
  String get mfgDocFormatsHint =>
      'Formatos aceites: PDF, JPG, PNG (máx. 10 MB cada).';

  @override
  String get mfgDocCnpjProof => 'Comprovante de inscrição no CNPJ';

  @override
  String get mfgDocArticles => 'Contrato social (ou equivalente)';

  @override
  String get mfgDocAddressProof =>
      'Comprovante de endereço (água/luz, até 3 meses)';

  @override
  String get mfgDeclarationLabel =>
      'Declaro que todas as informações são verdadeiras e que a falsidade implica responsabilização legal.';

  @override
  String get mfgSendForReview => 'Enviar para análise';

  @override
  String get mfgPendingTitle => 'Cadastro em análise';

  @override
  String get mfgPendingBody =>
      'Os seus documentos foram enviados com sucesso e estão a ser analisados pela nossa equipa.';

  @override
  String get mfgPendingSla => 'Prazo estimado: 24 a 48 horas úteis.';

  @override
  String get mfgPendingEmailNotice =>
      'Receberá um e-mail assim que o cadastro for aprovado.';

  @override
  String get mfgPendingProtocol => 'N.º do protocolo';

  @override
  String get mfgPendingStatusReview => 'Estado: em análise';

  @override
  String get mfgPendingSubmittedAt => 'Enviado em';

  @override
  String get mfgPendingSupport => 'Ajuda: suporte@app2cation.com';

  @override
  String get mfgCepInvalid => 'Informe um CEP com 8 dígitos.';

  @override
  String get mfgCepNotFound => 'CEP não encontrado.';

  @override
  String get mfgPickDoc => 'Anexar ficheiro';

  @override
  String get mfgRemoveDoc => 'Remover';

  @override
  String get mfgLogout => 'Sair';

  @override
  String get mfgOnboardFieldsRequired =>
      'Preencha todos os campos obrigatórios (CNPJ com 14 dígitos, CEP com 8, UF com 2 letras).';

  @override
  String get mfgAcceptDeclaration =>
      'Aceite a declaração para enviar o cadastro para análise.';

  @override
  String mfgDocMissingKind(Object title) {
    return 'Documento em falta: $title';
  }
}
