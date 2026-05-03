#!/usr/bin/env bash
# Gera Frontend/lib/app_version.dart a partir da linha version: do pubspec.
# Uso: ./scripts/sync_app_version_from_pubspec.sh [caminho-para-pubspec]
# Por defeito: Frontend/pubspec.yaml
#
# Badge visível: «V 1.46» = só MAJOR.MINOR (versão de produto). Não mostrar PATCH nem +BUILD
# (evita confusão com algo tipo «1.45.46»; o +BUILD é contador interno no pubspec).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUB="${1:-$ROOT/Frontend/pubspec.yaml}"
OUT="$ROOT/Frontend/lib/app_version.dart"
line=$(grep -E '^version:' "$PUB" | head -1)
full="${line#version:}"
full=$(echo "$full" | tr -d ' \r')

display=""
if [[ "$full" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(\+([0-9]+))?$ ]]; then
  display="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
elif [[ "$full" =~ ^([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  display="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
else
  echo "sync_app_version_from_pubspec: formato de version não reconhecido em $PUB: '$full'" >&2
  exit 1
fi

cat >"$OUT" <<EOF
// Gerado por scripts/sync_app_version_from_pubspec.sh — não editar; fonte: Frontend/pubspec.yaml
// Badge visível: V $display (só MAJOR.MINOR). Pubspec completo: $full
class AppVersion {
  static const String current = 'V $display';
}
EOF
