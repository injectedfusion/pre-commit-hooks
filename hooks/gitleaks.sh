#!/usr/bin/env bash
# gitleaks — scan staged changes for secrets using pattern matching.
# Catches 150+ secret types: API keys, tokens, passwords, connection strings.
#
# Requires: gitleaks in PATH
#   brew install gitleaks    (macOS)
#   apt-get install gitleaks (Debian/Ubuntu)
#
# Per-repo config: place .gitleaks.toml in repo root to customize rules.
# See: https://github.com/gitleaks/gitleaks#configuration

set -euo pipefail

if ! command -v gitleaks &> /dev/null; then
  echo "⚠ gitleaks not found — secret scanning skipped"
  echo "  Install: brew install gitleaks"
  exit 0
fi

repo_root="$(git rev-parse --show-toplevel)"

# Use per-repo config if present, otherwise use gitleaks defaults
config_args=()
if [[ -f "$repo_root/.gitleaks.toml" ]]; then
  config_args=(--config "$repo_root/.gitleaks.toml")
fi

if ! gitleaks protect --staged --source "$repo_root" --exit-code 1 --no-banner "${config_args[@]}" 2>&1; then
  echo ""
  echo "✗ gitleaks: secrets detected in staged changes"
  echo "  Remove secrets, then re-stage the corrected files."
  echo "  False positive? Add an allowlist entry to .gitleaks.toml"
  echo "  To bypass (emergency only): git commit --no-verify"
  exit 1
fi
