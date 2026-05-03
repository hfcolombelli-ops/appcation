# Lógica de desenvolvimento — App²cation

Este documento define **como** priorizamos, fatiamos e entregamos trabalho alinhado ao produto. É a referência única para “o que fazer a seguir” e “quando está pronto”.

## 1. Fontes de verdade

| Artefacto | Função |
|-----------|--------|
| [`docs/product/fluxo_app2cation.mermaid`](product/fluxo_app2cation.mermaid) | Navegação e jornadas por perfil (entrada única → quatro fluxos). |
| Catálogo de telas (especificação textual que o produto mantém) | Componentes e comportamento esperado por ecrã (IDs FAB-*, INS-*, APP-*, TRE-*). |
| [`Frontend/lib/product/screen_catalog_map.dart`](../Frontend/lib/product/screen_catalog_map.dart) | Mapeamento **ID → código actual** e notas de lacunas (actualizar ao fechar cada fatia). |

Se o código divergir do fluxograma sem decisão explícita, trata-se de **dívida de produto**: regista na secção “Decisões em aberto” no fim deste ficheiro ou num issue.

## 2. Princípios

1. **Fatias verticais** — Preferir uma funcionalidade **completa** (API + Flutter + l10n mínimo) a meias telas em vários perfis.
2. **Um fluxo de cada vez** — Dentro de um período curto, priorizar **um** dos quatro subgraphs do Mermaid (Treinando, Application, Instituição, Fabricante) para não partir UX nem contratos API.
3. **Contrato antes da pintura** — Campos novos ou estados novos: primeiro modelo/API ou contrato JSON estável; depois UI.
4. **Sem texto cru na UI** — Novas cópias em `app_pt.arb` / `app_en.arb` e `flutter gen-l10n`.
5. **Chrome partilhado** — Miúdos dos shells: [`Frontend/lib/theme/instructor_page_chrome.dart`](../Frontend/lib/theme/instructor_page_chrome.dart) (`instructorShellScaffold`, `instructorShellCard`). Refinar pixel-perfect **depois** da funcionalidade.
6. **Versão visível** — Baseline de produto `1.0.0+1` no `Frontend/pubspec.yaml`. Em cada entrega, `./scripts/bump_version.sh` incrementa o **minor** em 1 (leitura «1.0 → 1.1 → …» até 99 no segundo dígito; ao ultrapassar, sobe o **major** e o minor volta a 0), fixa **patch** em 0 e incrementa **build** (+n). O script regista também `app_version.dart`. Incluir estes ficheiros no commit da entrega.

## 3. Perfis técnicos (mapeamento IAM)

| Role API | Shell Flutter | Fluxo no Mermaid |
|----------|----------------|------------------|
| `trainee` | `TraineeShell` | Fluxograma 4 — Treinando |
| `instructor` | `InstructorShell` (área instrutor) | Fluxograma 3 — Application |
| `institution_admin` | `InstructorShell` (rotas `/institution/*`) | Fluxograma 2 — Instituição |
| `manufacturer_admin` | `ManufacturerShell` | Fluxograma 1 — Fabricante |

`RoleHome` em `main.dart` encaminha estes perfis; perfil ausente/desconhecido → `ProfileGateScreen`.

## 4. Fases sugeridas (ordem de investimento)

Ordem pensada para **fechar jornadas críticas** primeiro; ajustar se o negócio priorizar demo fabricante ou instituição.

### Fase 0 — Fundação (contínua)

- Fluxograma versionado; `ScreenCatalogMap` mantido; gates de perfil; chrome partilhado nos shells já migrados.
- **DoD:** `dart analyze` limpo nos módulos tocados; migrations Laravel aplicáveis documentadas no PR.

### Fase 1 — Fluxo Treinando (4)

Objetivo: TRE-ACC-01 → TRE-RES-01 fiéis ao catálogo (copy, passos, feedback de questões, resultado e certificado conforme API).

- Trabalhar por **step** no `TraineeShell` (`_step`), alinhado aos IDs `tre*` em `screen_catalog_map.dart`.
- **TRE-SAL-01** (`_WaitingPanel`): polling 3 s mantém-se; **pull-to-refresh** + botão «Actualizar estado» / «Refresh status» chamam `_bootstrap()` para sincronizar assim que o instrutor iniciar (útil em web e ligações lentas); **faixa offline** quando o *health* da API falha (copy PT/EN).
- **TRE-QUES-01** (`_QuestionnairePanel` / `_OptionTile`): opções com **Semantics** (`button`, `selected`, `excludeSemantics`); enunciado com **Semantics** (progresso + texto); caixa de feedback **liveRegion**; **Confirmar** desactivado sem opção seleccionada + **Tooltip** com a mesma copy do snack (`trnSnackPickOption`).
- **TRE-ACC-01** (`_JoinPanel`): copy + **`trnJoinIntroDetail`** / **`trnJoinAccessCodeHint`**; **validação visual** do código (`maxLength` 64, `FilteringTextInputFormatter` alfanumérico + hífen, contador `n/64`, helper «continuar a escrever» vs «formato válido», ícone tag/check); `joinTraining` normaliza trim + minúsculas antes do POST; **bloqueio + aviso** se API offline.
- **TRE-RES-01** (`_ResultPanel`): instituição; refresh/pull + **`/api/me/certificates`** + PDF + hint; **`/api/me/follow-up-assessments`** filtrado (inscrição/treino, `pending`) com **Responder** → `showTraineeFollowUpAssessmentDialog` (partilhado com o perfil **TRE-CON**); **faixa offline** (`trnResultOfflineHint`); **PDF** e **Responder** desactivados sem API + **Tooltip** com a mesma copy.
- **TRE-CON-01** (`_ProfilePanel` + `_LgpdConsentPanel`): **fechado (MVP+)** — pré-registo alinhado ao catálogo: passo visível no cabeçalho; instituição opcional explícita («sem instituição», sem pré-seleccionar primeiro hospital ao carregar lista); copy de apoio; lembrete pós-consentimento LGPD (exportar / excluir via menu).
- **DoD:** Happy path + erro/rede; l10n; actualizar comentários no map se algo ficar parcial.

### Fase 2 — Fluxo Application (3)

Objetivo: APP-DASH-01, APP-TRE-01, APP-SAL-01 estáveis; **APP-SAL-02** (pós-encerramento: tabela de resultados, repescagem explícita &lt; 7.0, encerramento definitivo / certificados) como fatia dedicada.

- Sala de comando (**APP-SAL-01**) e **Resultados** (**APP-SAL-02**): filtro local de participantes (nome/e-mail, debounce); APP-SAL-02 permanece rota dedicada `/instructor/resultados`. **APP-SAL-01:** *health* periódico + estado API na barra do shell; faixa offline + bloqueio de comandos de sessão / repescagem quando a API falha (`comandoOfflineHint`). **APP-SAL-02 / APP-DASH-01 / APP-TRE-01:** mesma origem `_InstructorApiReachability`; faixa + `instrOfflineHint` onde aplicável; desactivar export / encerrar / gravar treino / certificados em PDF offline.
- **DoD:** Fluxo Mermaid GA7→GA10 coberto sem dead-ends; API testada com treino `finished` ou estado equivalente.

### Fase 3 — Fluxo Instituição (2)

Objetivo: INS-DASH-01 / INS-PAR-01; **INS-SOL-01 Kanban** (três colunas + agendamento em lote); INS-APP-01; INS-REL-01 incremental.

- **DoD:** Gestor consegue fluxo FI6→FI9 no diagrama com UX próxima do catálogo.

### Fase 4 — Fluxo Fabricante (1)

Objetivo: FAB-DASH-01 evoluído; FAB-HOM-01/02 (fila + suspender/reactivar); FAB-ANA-01 por etapas (filtros → tabelas → visualizações avançadas).

- **DoD:** Documentação “parcial” no `ScreenCatalogMap` só até à próxima fatia; não deixar IDs marcados como não implementados sem plano.

## 5. Ciclo por fatia (checklist)

Para cada entrega (idealmente 1 PR ou série pequena coerente):

1. **Definir** ID(s) de catálogo e linha do Mermaid afectada.
2. **Backend** (se necessário): migration, policy de autorização, testes artisan relevantes.
3. **Frontend**: UI + estado + chamadas `ProductionApi`; tokens/chrome existentes.
4. **l10n** PT/EN + `flutter gen-l10n`.
5. **Actualizar** `screen_catalog_map.dart` (comentário por ID: implementado / parcial).
6. **`./scripts/bump_version.sh`** quando a alteração for visível ao utilizador-final (mantém a política da secção 2).
7. **Analisar**: `dart analyze`; PHP/tests conforme CI do repo.

## 6. Convenções rápidas

- **Versão Flutter:** `MAJOR.MINOR.PATCH+BUILD` no `pubspec.yaml`; badge usa `AppVersion.current` (gerado — não editar `app_version.dart` à mão).
- **API:** Controllers em `Backend/app/Http/Controllers/Api/`; respeitar roles e policies existentes.
- **Flutter:** Shells em `Frontend/lib/shell/`; evitar ficheiros monolíticos novos enormes — extrair widgets quando a fatia crescer.
- **Dropdowns Flutter recentes:** `DropdownButtonFormField` com `initialValue` + `ValueKey` quando o estado controlado mudar (evitar deprecações).
- **Exportação CSV/PDF (bytes):** na Web, `lib/util/download_bytes_web.dart` usa âncora de download; em restantes alvos Flutter, `download_bytes_stub.dart` grava via `package:file_saver` (mesmos pontos de chamada: fabricante, gestor, resultados pós-treino, certificado PDF no instrutor).

## 7. Decisões em aberto

_Registar aqui ou remover quando fechadas._

- **Sprint actual (exemplo):** APP-SAL-02 em `/instructor/resultados` com encerramento (`status: finished` ou comando realtime `close`): a API **emite/atualiza certificados** para todas as inscrições `completed` com nota ≥ limiar (`TrainingSession::issueCertificatesOnTrainingFinished`), além do PDF por participante (`GET /api/trainings/{id}/certificates/{id}/pdf`).
- APP-SAL-02: chips de situação por participante em `/instructor/resultados` — **fechado (MVP)** — Aprovado ≥7,0 · Insuficiente &lt;7,0 · Em recuperação · Sala de espera (`waiting`) · Em curso (`active`) · Concluído sem nota; **filtro local** de participantes (nome/e-mail, debounce), alinhado à sala de comando.
- INS-SOL-01: **fechado** — Kanban em `/institution/pedidos` (`pending`+`approved` · `scheduled` · `fulfilled`+`rejected`), agendamento em lote na fila, e validação na API (`scheduled` exige instrutor; `fulfilled` exige treino associado).
- INS-REL-01: **fechado** (MVP) — agregado por setor no `dashboard-summary` filtra por `trainings.institution_id`; perfil do treinando (`trainee_profiles` da instituição) com fallback «(sem setor)»; campos `total_enrollments`, `completed_count`, `completions` (com nota), `avg_score`; CSV/PDF e Flutter alinhados.
- FAB-ANA-01: **fechado (MVP)** — `monthly_trend` no `dashboard-summary` (união ordenada de meses com `enrollment_count` + `completed_count`); mantém `completed_by_month` / `enrollments_by_month` para consumo granular; vista combinada no Flutter; CSV/PDF uma tabela mensal; testes `FluxxoManufacturerDashboardTest`.
- FAB-DASH-01: **fechado (MVP)** — Início do fabricante: KPI + export CSV/PDF + cartão de evolução mensal (últimos 6 períodos de `monthly_trend`) + atalho «Abrir análises» (navega para índice 5 e recarrega dados filtrados).
- FAB-HOM-01: **fechado (MVP)** — `GET /api/credentials/manufacturer/queue` devolve **todos** os estados do fabricante (ordenados: pendente → aprovado → suspenso → recusado); filtros no `ManufacturerShell` com **contagens**; data de registo do pedido; na página Credenciamento (`InstructorShell`) ações Aprovar/Recusar em `pending`.
- FAB-HOM-02: **fechado (MVP)** — `PATCH /api/credentials/manufacturer/{id}` aceita `status: suspended` (só desde `approved`) e `approved` desde `suspended` (reactivar; preserva `fee_paid` se o cliente não enviar `fee_paid`); recusado não volta a aprovado sem novo pedido (`apply` → `pending`). Flutter: chip/filtro «Suspensos», botões Suspender / Reactivar; `localizedCredentialQueueStatus` + cores.
- FAB-EQP-01: **fechado (MVP+)** — `GET /api/manufacturer/equipment`: `sort` validado, `status` só `active`|`inactive`, `search` máx. 120; limite 200; Flutter: pesquisa com debounce + reload parcial da lista, chips categoria/estado, ordenação com `ValueKey`, contagem, limpar filtros.
- FAB-EQP-02: **fechado (MVP+)** — `ManufacturerEquipmentWizardScreen`: 2 passos com destaque visual; «Seguinte» valida nome/modelo/categoria; `POST`/`PUT` com validação de inteiros e intervalos; `helperText` por campo numérico + resumo; `DropdownButton` (categoria/estado); catálogo sincronizado com `_categoryId` (evita valor órfão).
- FAB-TRE-01: **fechado (MVP+)** — `GET /api/trainings?templates_only=1` com `search` (título, máx. 120), `status` (incl. `cancelled`), `sort`, limite 80; Flutter `ManufacturerShell` Produtos: chips estado, ordenação, contagem, limpar, debounce na pesquisa + recarga parcial só da lista, linha «Actualizado/Updated», `localizedTrainingLifecycleStatus` para cancelado.
- FAB-TRE-02: **fechado (MVP+)** — `ManufacturerTemplateEditorScreen`: vários blocos (título + perguntas), reordenar secções/perguntas, modo Editar/Pré-visualizar, 2–12 opções, `PopScope`, refresh; API GET ordena por bloco + `training_block`; testes API (GET vazio, POST com 6 opções).
- FAB-OPS-01: **fechado (MVP+)** — Operações: `GET /api/manufacturer/{documents|seasons|prizes}?search=` (LIKE, máx. 120) + paginação `{ items, meta }`; Flutter: debounce, «Carregar mais», recarga parcial; trim 120 no cliente; testes de pesquisa em documentos / prémios / épocas.
- “Sem perfil” no diagrama: **fechado (MVP+)** — `ProfileGateScreen` (`CORE-PROFILE-GATE`): conta + role da API; **«Actualizar sessão»** → `GET /api/auth/me`; **definir perfil (uma vez)** → `PATCH /api/me/role` (só se o `role` actual **não** for um dos mapeados na app) com treinando / instrutor / fabricante + campos de fabricante quando necessário; `VersionBadge`. **Em aberto:** alteração de `role` por utilizador já com perfil válido (continua só suporte / admin).

---

**Próximo passo imediato sugerido:** **Fase 2** (credenciamento `/instructor/credenciamento`, rotas instituição, ou refinamentos UX) ou **Fase 3** conforme prioridade. **APP-SAL-01/02**, **APP-DASH-01**, **APP-TRE-01** (rede via `_InstructorApiReachability`), **TRE-RES-01**, **TRE-QUES-01**, **TRE-ACC/TRE-SAL**, **TRE-CON-01** (MVP+), **FAB-HOM-01/02**, MVP+ fabricante no mapa e gate «Sem perfil» estão fechados (MVP+).
