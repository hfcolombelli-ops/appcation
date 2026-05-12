#!/usr/bin/env bash
# Abre psql ligado ao Postgres do projecto Railway (variáveis do serviço indicado).
#
# Uso:
#   ./scripts/railway_psql.sh              # pede ao railway connect para escolher
#   ./scripts/railway_psql.sh Postgres-u4Od   # nome exacto do cartão Postgres no canvas
#
# Pré-requisitos: brew install railway libpq && brew link --force libpq
# Na raiz do repo: railway login && railway link
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# libpq (Homebrew) instala o psql em opt/.../bin — muitas vezes não está no PATH até «brew link».
for _pq in "/opt/homebrew/opt/libpq/bin" "/usr/local/opt/libpq/bin"; do
  if [ -d "$_pq" ]; then
    PATH="$_pq:$PATH"
    export PATH
    break
  fi
done

if ! command -v railway >/dev/null 2>&1; then
  echo "Instala a Railway CLI: brew install railway" >&2
  echo "Guia: docs/GUIA_POSTGRES_LEIGO.md" >&2
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "O comando «psql» não foi encontrado." >&2
  echo "Corre na mesma máquina:" >&2
  echo "  brew install libpq && brew link --force libpq" >&2
  echo "Ou (sem link global) usa só no terminal:" >&2
  echo "  export PATH=\"/opt/homebrew/opt/libpq/bin:\$PATH\"" >&2
  echo "Guia: docs/GUIA_POSTGRES_LEIGO.md" >&2
  exit 1
fi

SERVICE="${1:-}"
if [ -n "$SERVICE" ]; then
  echo "A ligar ao serviço Railway: $SERVICE"
  exec railway connect "$SERVICE"
else
  echo "A abrir railway connect (escolhe o Postgres na lista)…"
  exec railway connect
fi
