# Roadmap App²cation — alinhamento ao documento Fluxxo

Plano em **fases ordenadas por dependência**. Marca itens conforme forem concluídos. O que já existe no código aparece em **Feito (baseline)**.

---

## Feito (baseline atual)

- Auth Sanctum, perfis (trainee, instructor, institution_admin, manufacturer_admin), LGPD (consentimento, export, exclusão).
- Treinos, blocos, questionário, inscrições, comandos realtime (seq + broadcast), polling no Flutter Web.
- Fabricante: perfil, equipamentos; templates oficiais (`is_official_template`), clonagem `from-template`.
- Credenciamento duplo (tabelas + APIs + UI parcial).
- Pedidos de treino (API + UI treinando/gestor parcial).
- Certificados (emissão ao aprovar nota ≥ mínimo).
- Repescagem operacional (limpar erros, reabrir inscrição).
- Dashboard instituição agregado por setor (LGPD).
- Painel “Fluxo premium” (orientação por perfil).

---

## Fase 1 — Consistência e “amarrar” o que já existe

**Objetivo:** nada de funcionalidade nova grande; tornar o fluxo utilizável ponta a ponta sem buracos.

| # | Entrega | Notas |
|---|---------|--------|
| 1.1 | `institution_admin`: fluxo claro para definir `users.institution_id` (registo, convite ou ecrã “vincular instituição”) | **Feito (MVP):** registo e-mail com instituição; banner “Vincule a sua instituição” + `PATCH /api/me/institution` no shell; **Google:** escolha de instituição no primeiro acesso + API grava `institution_id`. |
| 1.2 | UI gestor: ecrã dedicado **Pedidos de treino** (lista, aprovar, atribuir instrutor, ligar `fulfilled_training_id`) | **Feito:** `InstructorShell` → `/institution/pedidos` (`_InstitutionPedidosPage`). |
| 1.3 | Credenciamento: substituir `toString()` dos vínculos por lista legível + estados | **Feito:** filas gestor/fabricante em cartões com nome, e-mail, chip de estado (`_credentialStatusPt`) + texto de endosso; secção «Meus vínculos» já listava por instituição/fabricante. |
| 1.4 | Fabricante: fluxo mínimo **editar questionário do template** no shell (reutilizar sync existente) ou documentar “segunda conta instrutor” | **Feito:** `ManufacturerTemplateEditorScreen` + botão «Editar questionário» por template em `manufacturer_shell.dart`. |
| 1.5 | Testes de API (Pest/PHPUnit) para credenciais, templates, certificados, repescagem | **Feito (extensão):** `FluxxoPatchMeInstitutionTest` (`PATCH /api/me/institution`); `FluxxoGoogleAuthInstitutionTest` (Google gestor + `institution_id`). Já existiam `FluxxoCredentialsTest`, `FluxxoManufacturerTemplateTest`, `FluxxoCertificate*`, repescagem, etc. |

**Critério de saída:** instrutor homologado consegue clonar template → sessão → trainee aprova → certificado; gestor com `institution_id` vê pedidos e médias por setor.

---

## Fase 2 — Tempo real (documento: WebSockets)

**Objetivo:** substituir ou complementar polling por canal persistente onde fizer sentido.

| # | Entrega | Notas |
|---|---------|--------|
| 2.1 | Laravel **Reverb** (ou Pusher) + `broadcast` já usado em `TrainingSignal` | **Feito:** `TrainingSignal` → canal `training.{id}`; `config/broadcasting.php` + `.env.example`; `REVERB_CLIENT_HOST` para host WS no browser. |
| 2.2 | Flutter Web: subscrição ao canal do treino (`training.{id}`) ou user channel | **Feito:** `TrainingReverbListener` (`dart_pusher_channels`) + `GET /api/realtime/client-config`. |
| 2.3 | Fallback: manter polling se WS falhar | **Feito:** trainee poll 2s na sessão; instrutor comando 4s; WS chama refresh em `onSeq`. |
| 2.4 | Heartbeat / reconexão | **Feito:** `TrainingRealtimeLinkChip` + lifecycle do cliente; Reverb `ping_interval` / reconexão no listener. |

**Critério de saída:** comando do instrutor reflete no trainee em &lt;1s sem depender só do poll de 4s.

---

## Fase 3 — Fabricante (spec “Roberto / ArtMed”)

| # | Entrega | Notas |
|---|---------|--------|
| 3.1 | Estados `validation_status` completos + fluxo **pending_validation → active/rejected/pending_info** | **Feito:** faixa de 3 etapas (dados → análise → homologação) + chips/CTA em `manufacturer_shell.dart` (`_ValidationFlowStrip`); API já faz transições. |
| 3.2 | Upload de documentos (storage S3/local) + metadados | **Feito:** tabela `manufacturer_documents`; API usa `config('filesystems.default')` (S3 com `FILESYSTEM_DISK=s3` + AWS_*); metadados `document_kind`, `notes`, `mime_type`, `size_bytes`. |
| 3.3 | Notificação (e-mail ou fila) para “novo fabricante pendente” | **Feito:** `ManufacturerValidationRequested` (fila) ao `POST /api/manufacturer/request-validation`; opcional `NewManufacturerRegistered` no registo se `MANUFACTURER_NOTIFY_ON_REGISTRATION=true`; `ManufacturerReviewerNotifier`; worker com `QUEUE_CONNECTION` ≠ sync. |
| 3.4 | Versionamento formal de equipamento (novo registro v2, não editar histórico) | **Feito:** `parent_equipment_id` + `POST /api/manufacturer/equipment` com `parent_equipment_id`; `PUT`/`DELETE` bloqueados se existirem versões derivadas; UI fabricante «Nova versão» (`manufacturer_shell.dart`); testes `FluxxoManufacturerEquipmentVersionTest`. |
| 3.5 | Categorias de equipamento (Radiologia, CME, …) + filtros | **Feito:** `config/equipment.php` + `GET /api/catalog/equipment-categories`; fabricante filtra `GET /api/manufacturer/equipment?category=`; parque institucional filtra `equipment-templates` e `equipment` por `category` + chips em `_InstitutionParquePage`; testes `FluxxoEquipmentCategoriesTest`, `FluxxoInstitutionEquipmentParkTest`. |

---

## Fase 4 — Instituição (parque e governança)

| # | Entrega | Notas |
|---|---------|--------|
| 4.1 | **Parque tecnológico**: equipamentos por instituição, estados pending/active, vinculação a modelo fabricante | **Feito:** `InstitutionEquipmentController` + `_InstitutionParquePage`; `catalog_equipment_id`; pedido de treino valida `equipment_id` no parque da instituição; relação `TrainingRequest::equipment`; `GET /api/me/institution-park-equipment` (perfil treinando); UI treinando escolhe unidade; gestor vê «Parque: …» no pedido. |
| 4.2 | Solicitação de treino: motivos padronizados, prioridade, datas | **Feito (MVP):** `config/training_requests.php` + `POST /api/training-requests` + opções em `/api/catalog/training-request-options`; treinando: formulário em `trainee_shell.dart`; gestor: motivo/prioridade/datas em `_InstitutionPedidosPage`. |
| 4.3 | Dashboard: mais KPIs (taxa conclusão, por equipamento) mantendo **agregação** LGPD | **Feito:** `GET /api/institution/dashboard-summary` — `completion_summary`, `aggregated_by_equipment`, `aggregated_by_sector`, `trainings_count`, `avg_score_completed`; UI gestor em `_InstitutionDashboardView`; testes `FluxxoInstitutionDashboardKpiTest`. |
| 4.4 | Fluxo “instituição endossa instrutor para fabricante” | **Feito:** `endorsed_by_institution_id` + `endorsed_at` em `manufacturer_instructors`; `InstitutionManufacturerEndorsementController` (fila + `POST …/endorse`); fabricante só aprova homologação se existir vínculo institucional aprovado **e** endosso registado; UI gestor `Endossos ao fabricante`; testes `FluxxoCredentialsTest`. |

---

## Fase 5 — Sessão e repescagem (profundidade do doc)

| # | Entrega | Notas |
|---|---------|--------|
| 5.1 | Repescagem **por bloco** (métricas de acerto &lt;50% no bloco) | **Feito:** `TrainingSession::enrollmentBlockBelowHalfAccuracy` + validação em `RealtimeController` ao usar `training_block_id`; chips `_BlockMetricChip` / `block_metrics` no comando; repescagem global (sem bloco) inalterada. Teste `test_repescage_by_block_rejected_when_accuracy_not_below_half`. |
| 5.2 | Perguntas de repescagem: fase 1 = reutilizar erradas; fase 2 = banco de “variantes” ou integração LLM (opcional) | **Feito:** fase 1 já em `QuestionnaireController` + `recovery_question_ids`; fase 2: `questions.recovery_variant_group` + `metadata.repescage_variant_bank` + `TrainingSession::resolveRecoveryQuestionIdsForVariantBank`; sync questionário aceita grupo; UI instrutor (Treinamentos) interruptor «Banco de variantes»; testes `FluxxoRepescageVariantBankTest`. LLM: fora de âmbito. |
| 5.3 | Política de nota pós-repescagem (substituir vs média) configurável no treino | **Feito:** `metadata.post_repescage_score_policy` (`full_average` \| `recovery_only`) em `QuestionnaireController::tryCompleteEnrollment`; UI instrutor; `live-state` expõe política + texto PT para o treinando. |
| 5.4 | Pausa / retomar sessão com estado claro para trainees | **Feito:** `session_paused` + faixa laranja e bloqueio de respostas em `trainee_shell`; `live-state` / enrollments; reforço com texto da política de nota via `post_repescage_score_policy_label_pt`. |

---

## Fase 6 — Certificação e pós-treino

| # | Entrega | Notas |
|---|---------|--------|
| 6.1 | PDF do certificado (logo, código `APP²-…`, QR validação) | **Feito:** DomPDF + `CertificateController::downloadPdf`, view `certificates/pdf.blade.php`, QR (Endroid) para `config('app.certificate_verify_base_url')` + `/certificates/verify/{code}`; verificação **web** `GET /certificates/verify/{code}` e **API** `GET /api/public/certificates/verify/{code}` (mesmo handler, JSON com `Accept: application/json`); testes `FluxxoCertificatePdfVerifyTest`. |
| 6.2 | Validade + lembrete de **recertificação** (job diário) | **Feito:** `expires_at` em certificados; `certificates:send-recertification-reminders` + `SendRecertificationReminders`; agendamento em `routes/console.php`; `RecertificationReminderSend` + mail `RecertificationReminder`; `FluxxoRecertificationReminderTest`. |
| 6.3 | Reavaliações 10/15/30 dias (agendamento + mini questionário) | **Feito:** `config/follow_up.php`, `FollowUpAssessmentController`, `FollowUpScheduler` ao concluir questionário; `FluxxoFollowUpAssessmentTest`. |

---

## Fase 7 — Gamificação e analytics

| # | Entrega | Notas |
|---|---------|--------|
| 7.1 | Métricas por instrutor: treinos ministrados, média dos alunos, taxa aprovação | **Feito:** `GET /api/instructor/dashboard-summary` (`InstructorDashboardController`); Flutter `InstructorShell` → Dashboard com KPIs + treinos recentes. |
| 7.2 | Ranking / temporada (semestre) + metas configuráveis pelo fabricante | **Feito:** `seasons`, `leaderboard_entries`; fabricante CRUD + leaderboard + `recompute` (`ManufacturerSeasonController`); instrutor `GET /api/instructor/season-ranks` + secção «Ranking por temporada» no dashboard; testes `FluxxoSeasonLeaderboardTest`. |
| 7.3 | Prémios “somente registo” no MVP (descrição, sem pagamento) | **Feito:** `ManufacturerPrize` + `ManufacturerPrizeController`; catálogo público `GET /api/public/manufacturer-prizes?manufacturer_id=` (`ManufacturerPrizeCatalogController`); UI fabricante em `manufacturer_shell.dart`. |

---

## Fase 8 — Produto e operações

| # | Entrega | Notas |
|---|---------|--------|
| 8.1 | Apps iOS/Android (Flutter) ou PWA instalável | **Feito (MVP Web):** Flutter Web + `web/manifest.json` (standalone, ícones maskable, `shortcuts`), `web/index.html` (meta iOS/Android, `theme-color`), faixa «Instalar» com `beforeinstallprompt` (Chrome/Edge) + faixa iOS/Safari (Partilhar → ecrã inicial). **Nativo iOS/Android:** mesmo código Flutter — `flutter build ios` / `android` quando houver certificados/keystore. |
| 8.2 | Observabilidade: logs, métricas, alertas API | **Feito (MVP):** `X-Request-Id` + contexto `request_id` nos logs; `access_logs.request_id`; `GET /api/health` com `checks.database`, versão (`APP_VERSION`), 503 se BD falhar. Alertas: monitorizar health + logs agregados. |
| 8.3 | Carga e segurança: rate limit fino, auditoria de ações sensíveis | **Feito (MVP):** limitadores nomeados (`auth-*`, `public-read`, `api-user` 180/min por utilizador, `sensitive` 40/min, `gdpr-heavy` 6/h, `realtime-command` 90/min); tabela `security_audit_logs` + `SecurityAuditLog::record` em credenciais, validação fabricante, LGPD, pedidos treino, endosso, comandos realtime. |

**Estado:** as entregas **1.1–8.3** do plano Fluxxo neste documento estão cobertas no código (MVP). Evoluções passam a ser priorizadas na Fase 9.

---

## Fase 9 — Evolução (backlog pós-Fluxxo MVP)

| # | Ideia | Notas |
|---|--------|--------|
| 9.1 | Integração financeira | Prémios com pagamento, faturação ou subscrições — fora do MVP atual. |
| 9.2 | Builds nativos nas lojas | **MVP repo:** `Frontend/android` + `Frontend/ios` (incl. `Podfile`, **iOS mín. 15** por Firebase); `INTERNET` no manifest Android; **CI:** `android_apk` (Java 17) + `ios_compile` (`macos-latest`, `--no-codesign`). **IDs:** `com.appcation.app`. **Android:** `key.properties.example` → assinatura release opcional. **iOS loja:** certificados no Xcode; build local exige Xcode completo. |
| 9.3 | Relatórios e exportações | **MVP repo:** agregados + export **CSV**/**PDF** (rotas `.../export.csv|pdf`, audit log); digesto semanal + `users.weekly_dashboard_digest` + `PATCH /api/me/notification-preferences`; `FluxoPremiumPanel` (gestor/fabricante). |
| 9.4 | Qualidade e escala | **CI (MVP):** `.github/workflows/ci.yml` — **Backend:** `composer install`, `pint --test`, `php artisan test`; **Frontend:** `dart analyze`, `flutter test`, **`xvfb-run … flutter test integration_test/login_smoke_test.dart -d linux`** (smoke login com `integration_test` + runner Linux), `flutter build web --release`; **Android:** `flutter build apk --release` (Java 17); **iOS:** `pod install` + `flutter build ios --release --no-codesign` em `macos-latest`. **iOS:** `Flutter/Debug.xcconfig` e `Release.xcconfig` incluem opcionalmente os `Pods-Runner.*.xcconfig`. **i18n (MVP):** `flutter gen-l10n` — `lib/l10n/app_pt.arb` + `app_en.arb`; login/registo (`main.dart`); **shell instrutor** — navegação, top bar, banner; **dashboard**; **Novo treinamento**; **Sala de Comando** (seleção de treino, participantes, controlo de sessão, repescagem, snacks). Evolução: credenciamento, pedidos, parque, Fluxxo, outros shells, E2E Chrome, métricas. |

---

## Como usar este roadmap

1. Trabalhar **em ordem** dentro de cada fase; não pular 2.1–2.2 se o objetivo imediato é “tempo real”.
2. Em cada PR: referir `docs/FLUXXO_ROADMAP.md` e o **id** (ex.: 1.2).
3. Revisão semanal: marcar checkboxes (podes converter para issues GitHub).

---

## Expectativa de calendário (indicativa)

| Cenário | Fases 1–2 | Até fase 6 (certificação forte) | Doc completo + mobile + ops |
|---------|-----------|----------------------------------|-----------------------------|
| 1 dev focado | ~3–7 dias úteis | ~4–8 semanas | ~3–6 meses |
| Pequena equipa (2–3 devs) | ~2–4 dias úteis | ~2–4 semanas | ~1–3 meses |

“Terminar em dias” é realista para **Fase 1 completa + início da Fase 2**, não para o documento inteiro.
