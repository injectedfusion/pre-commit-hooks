#!/usr/bin/env bash
# require-signed-commits — fail if the commit being created will be unsigned.
# Prevents unsigned commits from entering the repo, enforcing GPG/SSH signing
# discipline especially important in agentic AI workflows.
#
# Checks git config commit.gpgsign is true, and that a signing key is configured.
# Gracefully skips if gpgsign is explicitly disabled (opt-out pattern).

set -euo pipefail

# Check if signing is configured
gpgsign="$(git config --get commit.gpgsign 2>/dev/null || echo 'false')"

if [[ "$gpgsign" != "true" ]]; then
  echo "✗ Unsigned commit blocked: commit.gpgsign is not set to true"
  echo ""
  echo "To enable commit signing:"
  echo "  git config --global commit.gpgsign true"
  echo "  git config --global user.signingkey <your-key>"
  echo ""
  echo "If using 1Password SSH agent:"
  echo "  git config --global gpg.format ssh"
  echo "  git config --global user.signingkey <your-public-key>"
  echo ""
  echo "To bypass (not recommended): git commit --no-verify"
  exit 1
fi

# Check a signing key is set
signingkey="$(git config --get user.signingkey 2>/dev/null || echo '')"
gpg_format="$(git config --get gpg.format 2>/dev/null || echo 'openpgp')"

if [[ -z "$signingkey" ]]; then
  echo "✗ Unsigned commit blocked: commit.gpgsign=true but user.signingkey is not set"
  echo ""
  echo "Set your signing key:"
  echo "  git config --global user.signingkey <your-key>"
  exit 1
fi

exit 0
