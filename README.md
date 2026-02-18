# pre-commit-hooks

Reusable [pre-commit](https://pre-commit.com/) hooks for GitOps, security, and multi-agent workflows.

## Hooks

| Hook | Description |
|------|-------------|
| `check-branch-staleness` | Fail if branch is behind the default branch. Prevents stale commits in multi-agent or team workflows. |
| `trivy-deps` | Scan dependency lockfiles for HIGH/CRITICAL CVEs. Catches what `trivy config` misses. |
| `no-hardcoded-secrets` | Detect hardcoded passwords and API keys in YAML files. |
| `require-signed-commits` | Block commits where `commit.gpgsign` is not `true` or `user.signingkey` is unset. |

## Usage

Add to your `.pre-commit-config.yaml`:

```yaml
- repo: https://github.com/injectedfusion/pre-commit-hooks
  rev: v0.1.0
  hooks:
    - id: check-branch-staleness
    - id: trivy-deps
    - id: no-hardcoded-secrets
```

Then install:

```bash
pip install pre-commit  # if not already installed
pre-commit install
```

## Personal hooks without per-repo setup

Some hooks (like `require-signed-commits`) enforce personal discipline that shouldn't be imposed on teammates. Use a global git hook instead — fires on every repo with zero per-repo setup:

```bash
mkdir -p ~/.config/git/hooks
git config --global core.hooksPath ~/.config/git/hooks
```

Create `~/.config/git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Personal check (e.g. signing)
gpgsign="$(git config --get commit.gpgsign 2>/dev/null || echo 'false')"
if [[ "$gpgsign" != "true" ]]; then
  echo "✗ Unsigned commit blocked: commit.gpgsign is not set to true"
  exit 1
fi
signingkey="$(git config --get user.signingkey 2>/dev/null || echo '')"
if [[ -z "$signingkey" ]]; then
  echo "✗ Unsigned commit blocked: user.signingkey is not set"
  exit 1
fi

# Chain to repo pre-commit config if present
repo_root="$(git rev-parse --show-toplevel)"
for config in "$repo_root/.pre-commit-config.local.yaml" "$repo_root/.pre-commit-config.yaml"; do
  if [[ -f "$config" ]]; then
    exec pre-commit run --config "$config" --hook-stage pre-commit
  fi
done
```

```bash
chmod +x ~/.config/git/hooks/pre-commit
```

## Hook Details

### check-branch-staleness

Fetches the remote default branch and fails if the current branch is behind. Auto-detects the default branch (`main`, `develop`, `master`, etc.) — no configuration needed.

Designed for workflows where multiple developers or AI agents work concurrently on the same repo, preventing commits against stale state.

**Behavior:**
- Skips on the default branch itself
- Gracefully skips if offline
- Shows which commits are missing

### trivy-deps

Scans dependency lockfiles for known vulnerabilities using [Trivy](https://aquasecurity.github.io/trivy/). Triggers on changes to:

`Cargo.lock`, `package-lock.json`, `go.sum`, `requirements.txt`, `poetry.lock`, `pnpm-lock.yaml`, `yarn.lock`, `Gemfile.lock`, `composer.lock`

**Requires:** `trivy` installed locally (`brew install trivy`).

### no-hardcoded-secrets

Regex-based detection of hardcoded credentials in YAML files. Catches patterns like:

```yaml
password: "AcT3kR9base64string..."
api_key: 'longSecretValue123...'
```

Ignores common templating patterns (`$__env{}`, `secretRef`, `existingSecret`).

## Requirements

- [pre-commit](https://pre-commit.com/) >= 2.0
- `git` (for `check-branch-staleness`)
- `trivy` (for `trivy-deps`, optional — hook skips gracefully if missing)

## License

MIT
