// Mapeamento catálogo de produto → implementação actual (Flutter Web).
// Fluxo de navegação: docs/product/fluxo_app2cation.mermaid
//
// Convenção API/backend: roles `trainee`, `instructor`, `institution_admin`, `manufacturer_admin`.
// “Application” no diagrama ≈ `instructor`; “Instituição” ≈ `institution_admin` (área gestor no InstructorShell).

/// IDs do catálogo (PARTE 2) para pesquisa no código e alinhamento incremental.
abstract final class ScreenCatalogMap {
  // --- Pós-login global (`main.dart` / `RoleHome`) — diagrama «Sem perfil» ---
  static const coreProfileGate = 'CORE-PROFILE-GATE'; // `ProfileGateScreen`: role vazio/desconhecido; cartão conta + role API; `PATCH /api/me/role` (trainee/instructor/manufacturer + dados fabricante); «Actualizar sessão» → `restore()`; sair; `VersionBadge`

  // --- Fabricante (ManufacturerShell) ---
  static const fabDash01 = 'FAB-DASH-01'; // Início: KPI + export + pré-visualização `monthly_trend` (6 meses) + CTA Análises
  static const fabEqp01 = 'FAB-EQP-01'; // Lista equipamentos (Produtos): API sort/status/search≤120 + limite 200; debounce + reload parcial, chips, `ValueKey` ordenação, limpar
  static const fabEqp02 = 'FAB-EQP-02'; // Wizard `manufacturer_equipment_wizard`: 2 passos, validações + helperText por intervalo, dropdown categoria/estado, sync categoria vs catálogo
  static const fabTre01 = 'FAB-TRE-01'; // Lista templates (`ManufacturerShell` Produtos): API `templates_only` + search≤120 + status/sort + limite 80; debounce + reload parcial lista; chips + linha actualizado
  static const fabTre02 = 'FAB-TRE-02'; // Editor questionário (`manufacturer_template_editor`): vários blocos (título + perguntas), reordenar secções/perguntas, Editar/Pré-visualizar, 2–12 opções, PopScope, refresh; GET questionnaire ordena por bloco + inclui `training_block`
  static const fabHom01 = 'FAB-HOM-01'; // Fila homologação instrutor↔fabricante: API lista todos os estados + filtros com contagens; UI fabricante + credenciamento instrutor
  static const fabHom02 = 'FAB-HOM-02'; // Pós-aprovação: `PATCH /api/credentials/manufacturer/{id}` com `status: suspended` (só desde `approved`) ou `approved` desde `suspended` (reactivar, sem re-enviar `fee_paid`); UI fila homologação `ManufacturerShell` + credenciamento `InstructorShell` (admin fabricante)
  static const fabAna01 = 'FAB-ANA-01'; // Análises fabricante (MVP): filtros + tabelas + `monthly_trend` alinhado + CSV/PDF combinados
  static const fabOps01 = 'FAB-OPS-01'; // Operações fabricante (ManufacturerShell → índice 3): épocas, prémios, documentos; `search` + paginação API (`items`/`meta`) + «Carregar mais» + debounce

  // --- Instituição (rotas /institution/* no InstructorShell) ---
  static const insDash01 = 'INS-DASH-01'; // Dashboard KPI instituição (_InstitutionDashboardView)
  static const insPar01 = 'INS-PAR-01'; // Parque (_InstitutionParquePage)
  static const insApp01 = 'INS-APP-01'; // Applications gestão (não dedicado; credenciais parciais)
  static const insSol01 = 'INS-SOL-01'; // Kanban 3 colunas + agendamento em lote (_InstitutionPedidosPage) + validações API
  static const insRel01 = 'INS-REL-01'; // Por setor no dashboard gestor: agregado por treinos da instituição + inscr./concl./com nota/média; CSV/PDF alinhados

  // --- Application / Instrutor (InstructorShell) ---
  static const appDash01 = 'APP-DASH-01'; // Dashboard instrutor (_DashboardPage)
  static const appTre01 = 'APP-TRE-01'; // Criar treino (/instructor/treinamento — _TreinamentoPage)
  static const appSal01 = 'APP-SAL-01'; // Sala de comando (/instructor/comando — _ComandoPage): controlo sessão, blocos, repescagem, Reverb; filtro local participantes (nome/e-mail, debounce)
  static const appSal02 = 'APP-SAL-02'; // /instructor/resultados — lista + filtro local participantes (nome/e-mail) + repescagem + encerrar treino + PDF/CSV + chips (waiting, active, recovery, aprovado, insuficiente, concluído sem nota)

  // --- Treinando (TraineeShell, steps internos) ---
  static const treAcc01 = 'TRE-ACC-01'; // Convite / entrada (_JoinPanel): join hash + copy + validação visual (64, filtro chars, contador, helper, ícone) + POST normalizado; aviso + botão desactivado se API offline (`_apiOnline`)
  static const treCon01 = 'TRE-CON-01'; // `_ProfilePanel` + `_LgpdConsentPanel`: cabeçalho «Perfil e instituição»; instituição opcional (item «Sem instituição», sem auto-selecção ao carregar catálogo); texto de apoio parque/pedidos; `ValueKey` no dropdown; pós-LGPD lembrete menu Privacidade
  static const treSal01 = 'TRE-SAL-01'; // Sala de espera (_WaitingPanel, _step 2): polling + RefreshIndicator + botão actualizar → _bootstrap(); faixa offline quando sem API
  static const treQues01 = 'TRE-QUES-01'; // Questionário + feedback imediato (is_correct API) + continuar; opções `_OptionTile` com Semantics; enunciado com `Semantics`+progresso; feedback `liveRegion`; «Confirmar» desactivado sem opção + `Tooltip` (`trnSnackPickOption`)
  static const treRes01 = 'TRE-RES-01'; // Resultado: banner ≥7/<7, nota, recuperação; instituição; refresh/pull + certificados + follow-ups `pending` (Responder) + PDF; hint cert; faixa offline + PDF/Responder desactivados + `Tooltip` (`trnResultOfflineHint`)
}
