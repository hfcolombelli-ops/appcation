#!/usr/bin/env bash
# Política App²cation — linha de produto: 1.0 → 1.1 → 1.2 → … (sem limite de MINOR).
#
# O Pub/Dart não aceita «1.0» nem «1.0+1» na linha version: — exige semver
# MAJOR.MINOR.PATCH. Mantemos PATCH sempre 0; o badge mostra só MAJOR.MINOR
# (ver scripts/sync_app_version_from_pubspec.sh). Sem +BUILD no pubspec.
#
# Cada ./scripts/bump_version.sh: MINOR +1, PATCH 0.
# Ex.: 1.0.0 → 1.1.0 → 1.2.0 → … → 1.100.0
#
# Uso antes de commit/deploy: ./scripts/bump_version.sh
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
  build=""
elif [[ "$full" =~ ^([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  echo "bump_version: formato legado MAJOR.MINOR+BUILD não suportado; use MAJOR.MINOR.0 em $PUB" >&2
  exit 1
else
  echo "Formato de version não suportado em $PUB: '$full' (use MAJOR.MINOR.0 ou MAJOR.MINOR.0+BUILD para migrar)." >&2
  exit 1
fi

minor=$((10#$minor + 1))
patch=0

new_full="${major}.${minor}.${patch}"

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i '' "s/^version:.*/version: $new_full/" "$PUB"
else
  sed -i "s/^version:.*/version: $new_full/" "$PUB"
fi

"$SYNC"
echo "Versão actualizada para $new_full (pubspec + app_version.dart). git add Frontend/pubspec.yaml Frontend/lib/app_version.dart"
