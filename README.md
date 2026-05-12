# App²cation

Monorepo do sistema App²cation com:

- `Backend/` Laravel API (auth, domínio inicial, rotas REST)
- `Frontend/` Flutter Web SPA (layout baseado no design Clinical Precision)
- `firebase.json` para Firebase Hosting
- `railway.toml` + `Dockerfile` para deploy no Railway

## Versionamento (obrigatório em cada commit)

A **única fonte de verdade** é `Frontend/pubspec.yaml` (`version: MAJOR.MINOR.0+BUILD`). O badge na UI mostra só **`V MAJOR.MINOR`** (ex.: `V 1.3`), gerado em `Frontend/lib/app_version.dart` pelo script de sync (não editar à mão).

1. **Uma vez por clone**, ativar o hook Git (bloqueia commit se a versão não subir):

   ```bash
   ./scripts/setup-githooks.sh
   ```

2. **Antes de cada commit**, incrementar versão e adicionar ficheiros:

   ```bash
   ./scripts/bump_version.sh
   git add Frontend/pubspec.yaml Frontend/lib/app_version.dart
   ```

   O hook `githooks/pre-commit` exige que `Frontend/pubspec.yaml` esteja no commit e que a linha `version` seja **diferente** do último commit. Emergência (só excecional): `SKIP_VERSION_HOOK=1 git commit ...`

## Desenvolvimento local — Backend com PostgreSQL

O Laravel aceita SQLite por defeito; em produção (Railway) usa-se **PostgreSQL**. Para desenvolver contra Postgres no teu computador:

1. `cd Backend && docker compose up -d` (sobe Postgres 16 na porta **5432**).
2. Copia `Backend/.env.example` para `Backend/.env` e define `DB_CONNECTION=pgsql` e `DB_URL=postgresql://appcation:appcation@127.0.0.1:5432/appcation?schema=public` (está comentado no exemplo).
3. `cd Backend && php artisan migrate`

Os testes PHPUnit continuam a usar SQLite em memória (`phpunit.xml`); o CI não precisa do Docker Postgres.

No host onde corres `php artisan`, o PHP precisa da extensão **pdo_pgsql** (ex.: macOS Homebrew: `brew install php` e extensão, ou imagem PHP com `pgsql`).

## Deploy

### Backend (Railway)

```bash
cd Backend
railway up --detach
```

### Frontend (Firebase Hosting), manual

Na raiz do monorepo (usa a API da Railway por defeito):

```bash
./scripts/deploy_web_hosting.sh
```

Ou só o build (sem Firebase):

```bash
BUILD_ONLY=1 ./scripts/deploy_web_hosting.sh
```

### Frontend (GitHub Actions)

Em cada push para `main` que altere `Frontend/`, `firebase.json`, `.firebaserc` ou o workflow, o ficheiro  
`.github/workflows/deploy-web-hosting.yml` faz **build Web** e **deploy** para o Hosting do projeto Firebase **appcation**.

**Secret obrigatório** no GitHub (Repository → *Settings* → *Secrets and variables* → *Actions*):

| Nome | Valor |
|------|--------|
| `FIREBASE_SERVICE_ACCOUNT` | JSON completo de uma conta de serviço com permissão para Firebase Hosting (ex.: “Firebase Hosting Admin” no projeto). No Firebase Console: *Project settings* → *Service accounts* → *Generate new private key*. Colar o conteúdo inteiro do ficheiro `.json` no secret. |

**Secret opcional:**

| Nome | Valor |
|------|--------|
| `API_BASE_URL` | URL pública da API Laravel, sem barra no fim. Se não existir, usa `https://appcation-production.up.railway.app`. |

Também podes disparar o workflow manualmente em *Actions* → *Deploy Web (Firebase Hosting)* → *Run workflow*.