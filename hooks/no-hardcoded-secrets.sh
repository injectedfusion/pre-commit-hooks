#!/usr/bin/env bash
# no-hardcoded-secrets — detect hardcoded credentials in YAML/config files.
# Catches patterns like: password: "AcT3kR9..." api_key: 'base64string...'
#
# Ignores common false positives: $__env{}, secretRef, existingSecret references.

set -euo pipefail

found=0
for f in "$@"; do
  if grep -En '(password|secret_key|api_key):\s*["'"'"'][A-Za-z0-9+/=]{12,}' "$f" 2>/dev/null | grep -v '\$__env\|secretRef\|existingSecret'; then
    found=1
  fi
done
exit $found
