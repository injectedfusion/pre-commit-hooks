#!/usr/bin/env bash
# trivy-deps — scan dependency lockfiles for known vulnerabilities.
# Catches CVEs in third-party libraries that trivy config (IaC scanning) misses.
#
# Requires: trivy (https://aquasecurity.github.io/trivy/)
# Targets: Cargo.lock, package-lock.json, go.sum, requirements.txt, poetry.lock,
#          pnpm-lock.yaml, yarn.lock, Gemfile.lock, composer.lock

set -euo pipefail

if ! command -v trivy &>/dev/null; then
  echo "⚠ trivy not found — skipping dependency vulnerability scan"
  echo "  Install: brew install trivy"
  exit 0
fi

exit_code=0
for f in "$@"; do
  dir=$(dirname "$f")
  output=$(trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 "$dir" 2>&1)
  result=$?
  if [ $result -ne 0 ]; then
    echo "$output"
    exit_code=1
  fi
done
exit $exit_code
