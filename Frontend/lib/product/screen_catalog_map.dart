// Mapeamento catálogo de produto → implementação actual (Flutter Web).
// Fluxo de navegação: docs/product/fluxo_app2cation.mermaid
//
// Convenção API/backend: roles `trainee`, `instructor`, `institution_admin`, `manufacturer_admin`.
// “Application” no diagrama ≈ `instructor`; “Instituição” ≈ `institution_admin` (área gestor no InstructorShell).

/// IDs do catálogo (PARTE 2) para pesquisa no código e alinhamento incremental.
abstract final class ScreenCatalogMap {
  // --- Fabricante (ManufacturerShell) ---
  static const fabDash01 = 'FAB-DASH-01'; // KPI + evolução (parcial: manufacturer_dashboard_summary)
  static const fabEqp01 = 'FAB-EQP-01'; // Lista equipamentos (ManufacturerShell → Produtos)
  static const fabEqp02 = 'FAB-EQP-02'; // Cadastro equipamento (formulário no shell)
  static const fabTre01 = 'FAB-TRE-01'; // Lista treinos oficiais (templates)
  static const fabTre02 = 'FAB-TRE-02'; // Editor (manufacturer_template_editor.dart)
  static const fabHom01 = 'FAB-HOM-01'; // Homologações (parcial: fluxo revisão / fila)
  static const fabAna01 = 'FAB-ANA-01'; // Análises detalhadas (não implementado como rota dedicada)

  // --- Instituição (rotas /institution/* no InstructorShell) ---
  static const insDash01 = 'INS-DASH-01'; // Dashboard KPI instituição (_InstitutionDashboardView)
  static const insPar01 = 'INS-PAR-01'; // Parque (_InstitutionParquePage)
  static const insApp01 = 'INS-APP-01'; // Applications gestão (não dedicado; credenciais parciais)
  static const insSol01 = 'INS-SOL-01'; // Kanban 3 colunas pedidos (_InstitutionPedidosPage — fila pending+approved · scheduled · fulfilled+rejected)
  static const insRel01 = 'INS-REL-01'; // Relatórios sectoriais (parcial no dashboard)

  // --- Application / Instrutor (InstructorShell) ---
  static const appDash01 = 'APP-DASH-01'; // Dashboard instrutor (_DashboardPage)
  static const appTre01 = 'APP-TRE-01'; // Criar treino (/instructor/treinamento — _TreinamentoPage)
  static const appSal01 = 'APP-SAL-01'; // Sala de comando (/instructor/comando — _ComandoPage)
  static const appSal02 = 'APP-SAL-02'; // /instructor/resultados — GA10 + PDF + emissão manual + CSV certificados + chips + repescagem

  // --- Treinando (TraineeShell, steps internos) ---
  static const treAcc01 = 'TRE-ACC-01'; // Convite / entrada (join hash + login)
  static const treCon01 = 'TRE-CON-01'; // Confirmação dados / instituição (step perfil)
  static const treSal01 = 'TRE-SAL-01'; // Sala de espera (_step waiting)
  static const treQues01 = 'TRE-QUES-01'; // Questionário + feedback imediato (is_correct API) + continuar
  static const treRes01 = 'TRE-RES-01'; // Resultado (banner >=7 / <7, nota, nota recuperação)
}
