#!/usr/bin/env bash
set -euo pipefail

SKIP_PUB_GET="${SKIP_PUB_GET:-false}"
SKIP_ANALYZE="${SKIP_ANALYZE:-false}"

section() {
  echo ""
  echo "===================="
  echo "$1"
  echo "===================="
}

section "AI_LMS_PRD - Code Health Checks"

if [ "$SKIP_PUB_GET" != "true" ]; then
  section "flutter pub get"
  flutter pub get
fi

if [ "$SKIP_ANALYZE" != "true" ]; then
  section "flutter analyze"
  flutter analyze --no-fatal-infos
fi

section "dependency_validator (technical debt dependencies)"
dart run dependency_validator

section "dart fix (dry-run)"
dart fix --dry-run

section "DCM (if installed)"
if command -v dcm >/dev/null 2>&1; then
  dcm check-dependencies lib
  dcm check-unused-code lib
  dcm check-unused-files lib
else
  echo "DCM not installed. Skipping. (See docs to install)"
fi

section "DONE"
