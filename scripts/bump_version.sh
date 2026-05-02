#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/VERSION"
FRONTEND_VERSION_FILE="$ROOT_DIR/Frontend/lib/app_version.dart"

if [[ ! -f "$VERSION_FILE" ]]; then
  echo "0.1" > "$VERSION_FILE"
fi

current="$(tr -d '[:space:]' < "$VERSION_FILE")"
next="$(awk "BEGIN { printf \"%.1f\", $current + 0.1 }")"

echo "$next" > "$VERSION_FILE"

cat > "$FRONTEND_VERSION_FILE" <<EOF
class AppVersion {
  static const String current = 'V $next';
}
EOF

echo "Version updated to V $next"
