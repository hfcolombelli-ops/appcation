# Fase 2 — Treinando por link / QR dinâmico

## Objectivo

Substituir o fluxo actual (treinando autenticado + colagem manual de `join_hash` em [`trainee_shell.dart`](../../Frontend/lib/shell/trainee_shell.dart)) por um **URL público** (e QR) que leva a um **registo mínimo** e entrada directa no treino.

## Estado actual (backend)

- [`EnrollmentController::join`](../../Backend/app/Http/Controllers/Api/EnrollmentController.php): `POST /api/enrollments/join` com `join_hash`, exige `auth:sanctum` e `role === trainee` (mantém-se para treinandos **já** autenticados).
- [`PublicTrainingRegisterJoinController`](../../Backend/app/Http/Controllers/Api/PublicTrainingRegisterJoinController.php): `POST /api/public/trainings/register-and-join` — registo + inscrição sem sessão prévia.
- [`Training`](../../Backend/app/Models/Training.php): campo `join_hash` estável por treino.

## Direcção técnica

1. **Token rotativo** (recomendado): tabela `training_access_tokens` com `training_id`, `token_hash`, `expires_at`, `revoked_at`, `single_use`. O QR codifica `https://<app>/t/<plainToken>`. Cada sessão ou reemissão gera novo token; invalida anteriores se necessário.
2. **Alternativa mínima** (implementada): reutilizar `join_hash` com `GET /api/public/trainings/join-preview/{hash}` + `POST /api/public/trainings/register-and-join` (`join_hash`, `name`, `email`, `password`, `password_confirmation`) que cria `User` treinando + `Enrollment` numa transacção, com throttle `auth-register` e CAPTCHA opcional no futuro.

## Flutter

- Rota dedicada (ex.: `/t` ou `/join-training`) com formulário nome + e-mail + palavra-passe + confirmação LGPD.
- Após sucesso: `AuthSession` com token devolvido pelo endpoint público (igual ao fluxo de convite de gestor).

## Segurança

- Rate limit por IP e por `join_hash` / token.
- Não listar treinos; só metadados limitados na pré-visualização pública.

## Referência API

- `GET /api/public/trainings/join-preview/{join_hash}` — resposta mínima para landing (sem dados sensíveis).
- `POST /api/public/trainings/register-and-join` — corpo JSON: `join_hash`, `name`, `email`, `password`, `password_confirmation`. Resposta `201`: `token` (Sanctum), `user`, `training`. Só aceita treinos com `status` em `scheduled` ou `in_progress`.
