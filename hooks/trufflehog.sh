#!/usr/bin/env bash
# trufflehog — scan for verified secrets using entropy analysis + pattern matching.
# Uses --only-verified to suppress noise: only reports secrets that were confirmed
# active against the issuing service (reduces false positives significantly).
#
# Requires: trufflehog in PATH
#   brew install trufflehog    (macOS)
#   See: https://github.com/trufflesecurity/trufflehog#installation
#
# Note: complements gitleaks (pattern-based). TruffleHog's verification step
# catches live secrets that pattern-only tools would flag as low-confidence.

set -euo pipefail

if ! command -v trufflehog &> /dev/null; then
  echo "⚠ trufflehog not found — verified secret scanning skipped"
  echo "  Install: brew install trufflehog"
  exit 0
fi

repo_root="$(git rev-parse --show-toplevel)"

if ! trufflehog git "file://$repo_root" \
    --since-commit HEAD \
    --only-verified \
    --fail \
    --no-update \
    2>&1; then
  echo ""
  echo "✗ trufflehog: verified live secrets detected"
  echo "  Revoke these credentials immediately, then remove from code."
  echo "  To bypass (emergency only): git commit --no-verify"
  exit 1
fi
