#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${HOME}/.claude"

echo "==> Backing up local Claude Code configuration into repo..."

if [ ! -d "${CLAUDE_DIR}" ]; then
    echo "❌ Error: ${CLAUDE_DIR} does not exist!" >&2
    exit 1
fi

# 1. Sync skills
if [ -d "${CLAUDE_DIR}/skills" ]; then
    echo "-> Syncing skills..."
    mkdir -p "${REPO_ROOT}/skills"
    rsync -av --delete --exclude=".git" "${CLAUDE_DIR}/skills/" "${REPO_ROOT}/skills/"
fi

# 2. Sync agents
if [ -d "${CLAUDE_DIR}/agents" ]; then
    echo "-> Syncing agents..."
    mkdir -p "${REPO_ROOT}/agents"
    rsync -av --delete --exclude=".git" "${CLAUDE_DIR}/agents/" "${REPO_ROOT}/agents/"
fi

# 3. Sync rules
if [ -d "${CLAUDE_DIR}/rules" ]; then
    echo "-> Syncing rules..."
    mkdir -p "${REPO_ROOT}/rules"
    rsync -av --delete --exclude=".git" "${CLAUDE_DIR}/rules/" "${REPO_ROOT}/rules/"
fi

# 4. Verify security scan
"${REPO_ROOT}/scripts/sanitize.sh"

echo "✅ Backup complete! Ready to commit."
