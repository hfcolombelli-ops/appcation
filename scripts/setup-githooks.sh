#!/usr/bin/env bash
# Configura este repositório para usar githooks/ (pre-commit de versão).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
git config core.hooksPath githooks
chmod +x githooks/pre-commit 2>/dev/null || true
echo "OK: core.hooksPath=githooks (pre-commit ativo neste clone)."
