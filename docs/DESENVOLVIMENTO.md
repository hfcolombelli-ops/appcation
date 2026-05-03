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
- **DoD:** Happy path + erro/rede; l10n; actualizar comentários no map se algo ficar parcial.

### Fase 2 — Fluxo Application (3)

Objetivo: APP-DASH-01, APP-TRE-01, APP-SAL-01 estáveis; **APP-SAL-02** (pós-encerramento: tabela de resultados, repescagem explícita &lt; 7.0, encerramento definitivo / certificados) como fatia dedicada.

- Sala de comando já cobre parte de APP-SAL-01; APP-SAL-02 pode ser **nova rota** ou modo na mesma página — decidir na fatia e documentar no map.
- **DoD:** Fluxo Mermaid GA7→GA10 coberto sem dead-ends; API testada com treino `finished` ou estado equivalente.

### Fase 3 — Fluxo Instituição (2)

Objetivo: INS-DASH-01 / INS-PAR-01; **INS-SOL-01 Kanban** (três colunas + agendamento em lote); INS-APP-01; INS-REL-01 incremental.

- **DoD:** Gestor consegue fluxo FI6→FI9 no diagrama com UX próxima do catálogo.

### Fase 4 — Fluxo Fabricante (1)

Objetivo: FAB-DASH-01 evoluído; FAB-HOM-01/02; FAB-ANA-01 por etapas (filtros → tabelas → visualizações avançadas).

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

## 7. Decisões em aberto

_Registar aqui ou remover quando fechadas._

- **Sprint actual (exemplo):** APP-SAL-02 em `/instructor/resultados` com encerramento (`status: finished` ou comando realtime `close`): a API **emite/atualiza certificados** para todas as inscrições `completed` com nota ≥ limiar (`TrainingSession::issueCertificatesOnTrainingFinished`), além do PDF por participante (`GET /api/trainings/{id}/certificates/{id}/pdf`).
- APP-SAL-02: chips de situação por participante (Aprovado ≥7,0 · Insuficiente &lt;7,0 · Em recuperação · Em curso / sem nota).
- INS-SOL-01: Kanban em UI sobre `status` (`pending`+`approved` · `scheduled` · `fulfilled`+`rejected`; pedidos com estado futuro caem na fila).
- “Sem perfil” no diagrama: wizard com mudança de `role` na API vs. apenas registo inicial (actual).

---

**Próximo passo imediato sugerido:** fechar **INS-SOL-01** (Kanban de pedidos de treino na área instituição) ou PDF institucional agregado no dashboard do gestor, conforme prioridade de demo.
