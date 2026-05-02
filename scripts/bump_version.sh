#!/usr/bin/env bash
# Incrementa o build number em Frontend/pubspec.yaml (ex.: 1.0.1+3 → 1.0.1+4)
# e regera Frontend/lib/app_version.dart.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PUB="$ROOT_DIR/Frontend/pubspec.yaml"
SYNC="$ROOT_DIR/scripts/sync_app_version_from_pubspec.sh"

line=$(grep -E '^version:' "$PUB" | head -1)
full="${line#version:}"
full=$(echo "$full" | tr -d ' \r')

new_full=""
if [[ "$full" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)$ ]]; then
  name="${BASH_REMATCH[1]}"
  build="${BASH_REMATCH[2]}"
  new_full="${name}+$((build + 1))"
elif [[ "$full" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  new_full="${major}.${minor}.$((patch + 1))+1"
else
  echo "Formato de version não suportado em $PUB: '$full' (use x.y.z+n ou x.y.z)." >&2
  exit 1
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i '' "s/^version:.*/version: $new_full/" "$PUB"
else
  sed -i "s/^version:.*/version: $new_full/" "$PUB"
fi

"$SYNC"
chmod +x "$SYNC" 2>/dev/null || true
echo "Versão atualizada para $new_full (pubspec + app_version.dart). Faça git add Frontend/pubspec.yaml Frontend/lib/app_version.dart"
