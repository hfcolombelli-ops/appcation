#!/usr/bin/env bash
# Build Flutter Web com API de produção e publica no Firebase Hosting.
# Uso:
#   ./scripts/deploy_web_hosting.sh
# Outra API:
#   API_BASE_URL=https://teu-backend.up.railway.app ./scripts/deploy_web_hosting.sh
# Só build (sem firebase):
#   BUILD_ONLY=1 ./scripts/deploy_web_hosting.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
API_BASE_URL="${API_BASE_URL:-https://appcation-production.up.railway.app}"
FIREBASE_PROJECT="${FIREBASE_PROJECT:-appcation}"

echo "→ API_BASE_URL=$API_BASE_URL"
echo "→ Firebase project=$FIREBASE_PROJECT"

cd "$ROOT_DIR/Frontend"
flutter build web --release \
  --dart-define="API_BASE_URL=$API_BASE_URL"

if [[ "${BUILD_ONLY:-0}" == "1" ]]; then
  echo "→ BUILD_ONLY=1: não executando firebase deploy."
  exit 0
fi

cd "$ROOT_DIR"
firebase deploy --only hosting --project "$FIREBASE_PROJECT"

echo "→ Hosting publicado com bundle apontando para $API_BASE_URL"
