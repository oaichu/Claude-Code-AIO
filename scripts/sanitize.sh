#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Scanning for potential secrets and credentials in repo..."

# Pattern matches typical API keys and tokens:
# - Anthropic / OpenAI keys: sk-[a-zA-Z0-9]{20,}
# - GitHub PATs: gho_[a-zA-Z0-9]{20,}, ghp_[a-zA-Z0-9]{20,}
# - Generic secrets
SECRET_PATTERN='(sk-[a-zA-Z0-9_-]{20,}|gho_[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,}|github_pat_[a-zA-Z0-9_-]{20,})'

LEAKS=$(grep -rnEI "${SECRET_PATTERN}" "${REPO_ROOT}" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude="sanitize.sh" \
    --exclude="*.template" || true)

if [ -n "${LEAKS}" ]; then
    echo "❌ SECURITY ALERT: Potential secrets detected in repository files!" >&2
    echo "${LEAKS}" >&2
    exit 1
fi

echo "✅ Security check passed: No credentials or tokens found."
