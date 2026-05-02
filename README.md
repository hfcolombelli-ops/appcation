# App²cation

Monorepo do sistema App²cation com:

- `Backend/` Laravel API (auth, domínio inicial, rotas REST)
- `Frontend/` Flutter Web SPA (layout baseado no design Clinical Precision)
- `firebase.json` para Firebase Hosting
- `railway.toml` + `Dockerfile` para deploy no Railway

## Versionamento (obrigatório em cada commit)

A **única fonte de verdade** é `Frontend/pubspec.yaml` (`version: x.y.z+n`). O badge na UI vem de `Frontend/lib/app_version.dart`, **gerado** a partir do pubspec (não editar o número à mão).

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