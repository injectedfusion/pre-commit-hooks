# pre-commit-hooks

Reusable [pre-commit](https://pre-commit.com/) hooks for GitOps, security, and multi-agent workflows.

## Hooks

| Hook | Description |
|------|-------------|
| `check-branch-staleness` | Fail if branch is behind the default branch. Prevents stale commits in multi-agent or team workflows. |
| `trivy-deps` | Scan dependency lockfiles for HIGH/CRITICAL CVEs. Catches what `trivy config` misses. |
| `no-hardcoded-secrets` | Detect hardcoded passwords and API keys in YAML files. |

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
