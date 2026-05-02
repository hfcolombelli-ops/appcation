#!/usr/bin/env bash
# Build Flutter Web com API de produção e publica no Firebase Hosting.
# Uso:
#   ./scripts/deploy_web_hosting.sh
# Outra API:
#   API_BASE_URL=https://teu-backend.up.railway.app ./scripts/deploy_web_hosting.sh
# Só build (sem firebase):
#   BUILD_ONLY=1 ./scripts/deploy_web_hosting.sh
#
# Firebase Web (opcional): copia Frontend/dart_defines.production.env.example para
# Frontend/dart_defines.production.env e preenche FIREBASE_WEB_* (Console Firebase → app Web).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
API_BASE_URL="${API_BASE_URL:-https://appcation-production.up.railway.app}"
FIREBASE_PROJECT="${FIREBASE_PROJECT:-appcation}"
DEFINES_FILE="$ROOT_DIR/Frontend/dart_defines.production.env"

echo "→ API_BASE_URL=$API_BASE_URL"
echo "→ Firebase project=$FIREBASE_PROJECT"

cd "$ROOT_DIR/Frontend"
if [[ -f "$DEFINES_FILE" ]]; then
  echo "→ Build com $DEFINES_FILE + API_BASE_URL=$API_BASE_URL (variável de ambiente prevalece)"
  tmp_defs="$(mktemp)"
  printf 'API_BASE_URL=%s\n' "$API_BASE_URL" >"$tmp_defs"
  grep -Ev '^[[:space:]]*API_BASE_URL=' "$DEFINES_FILE" >>"$tmp_defs"
  flutter build web --release --no-wasm-dry-run \
    --dart-define-from-file="$tmp_defs"
  rm -f "$tmp_defs"
else
  echo "→ Sem $DEFINES_FILE: só API_BASE_URL (Firebase.init omitido no Web — ver dart_defines.production.env.example)"
  flutter build web --release --no-wasm-dry-run \
    --dart-define="API_BASE_URL=$API_BASE_URL"
fi

if [[ "${BUILD_ONLY:-0}" == "1" ]]; then
  echo "→ BUILD_ONLY=1: não executando firebase deploy."
  exit 0
fi

cd "$ROOT_DIR"
firebase deploy --only hosting --project "$FIREBASE_PROJECT"

echo "→ Hosting publicado com bundle apontando para $API_BASE_URL"
