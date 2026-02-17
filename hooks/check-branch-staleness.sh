#!/usr/bin/env bash
# check-branch-staleness — fail if branch is behind the default branch.
# Prevents concurrent agents/humans from committing against stale state.
#
# Auto-detects the default branch (main, master, develop, etc.).
# Gracefully skips if offline or on the default branch itself.

set -euo pipefail

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

# Detect default branch from remote HEAD
default_branch="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')"
if [[ -z "$default_branch" ]]; then
  default_branch="$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')"
fi
if [[ -z "$default_branch" ]]; then
  echo "⚠ Could not detect default branch — skipping staleness check"
  exit 0
fi

# Skip on the default branch itself
if [[ "$branch" == "$default_branch" || "$branch" == "HEAD" ]]; then
  exit 0
fi

# Fetch latest — if offline, warn but don't block
if ! git fetch origin "$default_branch" --quiet 2>/dev/null; then
  echo "⚠ Could not fetch origin/$default_branch (offline?) — skipping staleness check"
  exit 0
fi

behind="$(git rev-list --count "HEAD..origin/$default_branch" 2>/dev/null)"
if ! [[ "$behind" =~ ^[0-9]+$ ]]; then
  echo "⚠ Could not determine how far behind origin/$default_branch — skipping"
  exit 0
fi

if [[ "$behind" -gt 0 ]]; then
  echo "Branch '$branch' is $behind commit(s) behind origin/$default_branch"
  echo ""
  echo "Recent commits on $default_branch not in this branch:"
  git log --oneline "HEAD..origin/$default_branch" | head -5
  [[ "$behind" -gt 5 ]] && echo "  ... and $((behind - 5)) more"
  echo ""
  echo "Fix: git fetch origin $default_branch && git rebase origin/$default_branch"
  exit 1
fi
