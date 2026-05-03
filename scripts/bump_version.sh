#!/usr/bin/env bash
# Política App²cation (produto visível no badge = só «1.x», sem terceiro dígito nem +build):
#   - Baseline: 1.0.0+1 no pubspec → badge «V 1.0» (gerado por sync_app_version_from_pubspec.sh).
#   - Cada entrega: MINOR +1 (leitura 1.0 → 1.1 → … → 1.99); PATCH fica 0; BUILD (+n) +1.
#   - MINOR > 99: MAJOR +1, MINOR 0.
#
# Pubspec mantém MAJOR.MINOR.0+BUILD (exigência Flutter); o utilizador vê só V MAJOR.MINOR.
#
# Ex.: 1.0.0+1 → 1.1.0+2 → … → 1.99.0+100 → 2.0.0+101
#
# Uso: ./scripts/bump_version.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PUB="$ROOT_DIR/Frontend/pubspec.yaml"
SYNC="$ROOT_DIR/scripts/sync_app_version_from_pubspec.sh"

line=$(grep -E '^version:' "$PUB" | head -1)
full="${line#version:}"
full=$(echo "$full" | tr -d ' \r')

major="" minor="" patch="" build=""

if [[ "$full" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  build="${BASH_REMATCH[4]}"
elif [[ "$full" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  build="0"
else
  echo "Formato de version não suportado em $PUB: '$full' (use MAJOR.MINOR.PATCH+BUILD ou MAJOR.MINOR.PATCH)." >&2
  exit 1
fi

minor=$((10#$minor + 1))
if (( minor > 99 )); then
  major=$((10#$major + 1))
  minor=0
fi
patch=0
build=$((10#$build + 1))

new_full="${major}.${minor}.${patch}+${build}"

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i '' "s/^version:.*/version: $new_full/" "$PUB"
else
  sed -i "s/^version:.*/version: $new_full/" "$PUB"
fi

"$SYNC"
echo "Versão actualizada para $new_full (pubspec + app_version.dart). git add Frontend/pubspec.yaml Frontend/lib/app_version.dart"
