#!/usr/bin/env bash
# Gera Frontend/lib/app_version.dart a partir da linha version: do pubspec.
# Uso: ./scripts/sync_app_version_from_pubspec.sh [caminho-para-pubspec]
# Por defeito: Frontend/pubspec.yaml
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUB="${1:-$ROOT/Frontend/pubspec.yaml}"
OUT="$ROOT/Frontend/lib/app_version.dart"
line=$(grep -E '^version:' "$PUB" | head -1)
full="${line#version:}"
full=$(echo "$full" | tr -d ' \r')
name="${full%%+*}"
cat >"$OUT" <<EOF
// Gerado por scripts/sync_app_version_from_pubspec.sh — não editar; fonte: Frontend/pubspec.yaml
class AppVersion {
  static const String current = 'V $name';
}
EOF
