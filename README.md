# App²cation

Monorepo do sistema App²cation com:

- `Backend/` Laravel API (auth, domínio inicial, rotas REST)
- `Frontend/` Flutter Web SPA (layout baseado no design Clinical Precision)
- `firebase.json` para Firebase Hosting
- `railway.toml` + `Dockerfile` para deploy no Railway

## Versionamento visual

Todas as telas exibem versão no canto inferior esquerdo.

- Arquivo fonte: `VERSION`
- Espelho no frontend: `Frontend/lib/app_version.dart`
- Script de incremento: `scripts/bump_version.sh`

Antes de cada commit:

```bash
./scripts/bump_version.sh
```

## Deploy

### Backend (Railway)

```bash
cd Backend
railway up --detach
```

### Frontend (Firebase Hosting)

```bash
cd ..
flutter build web --release
npx firebase-tools deploy --only hosting --project <firebase-project-id>
```