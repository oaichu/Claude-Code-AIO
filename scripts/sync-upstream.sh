#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR=$(mktemp -d /tmp/claude-code-aio-sync-XXXXXX)
trap 'rm -rf "${WORK_DIR}"' EXIT

echo "========================================================"
echo "    Claude Code AIO — Upstream Sync Engine             "
echo "========================================================"

UPSTREAMS=(
    "game-studios|https://github.com/Donchitos/Claude-Code-Game-Studios.git|main"
    "superpowers|https://github.com/obra/superpowers.git|main"
    "ponytail|https://github.com/DietrichGebert/ponytail.git|main"
    "autoharness|https://github.com/tigerless-labs/autoharness.git|main"
)

for ENTRY in "${UPSTREAMS[@]}"; do
    IFS='|' read -r NAME URL BRANCH <<< "${ENTRY}"
    echo "==> Fetching latest from ${NAME} (${URL})..."
    TARGET_DIR="${WORK_DIR}/${NAME}"
    git clone --depth 1 -b "${BRANCH}" "${URL}" "${TARGET_DIR}" 2>/dev/null || {
        echo "⚠️ Warning: Failed to clone ${NAME}, skipping..."
        continue
    }

    # 1. Sync skills if present
    if [ -d "${TARGET_DIR}/skills" ]; then
        echo "   -> Updating skills from ${NAME}..."
        for SKILL_PATH in "${TARGET_DIR}/skills"/*; do
            if [ -d "${SKILL_PATH}" ]; then
                SKILL_NAME=$(basename "${SKILL_PATH}")
                # Don't overwrite if it conflicts with custom frontend/reasoning skills
                mkdir -p "${REPO_ROOT}/skills/${SKILL_NAME}"
                cp -rf "${SKILL_PATH}/"* "${REPO_ROOT}/skills/${SKILL_NAME}/"
            fi
        done
    fi

    # 2. Sync agents if present
    if [ -d "${TARGET_DIR}/agents" ]; then
        echo "   -> Updating agents from ${NAME}..."
        mkdir -p "${REPO_ROOT}/agents"
        cp -rf "${TARGET_DIR}/agents/"* "${REPO_ROOT}/agents/"
    fi

    # 3. Sync rules if present
    if [ -d "${TARGET_DIR}/rules" ]; then
        echo "   -> Updating rules from ${NAME}..."
        mkdir -p "${REPO_ROOT}/rules"
        cp -rf "${TARGET_DIR}/rules/"* "${REPO_ROOT}/rules/"
    fi
done

# Run security sanitize check
echo "==> Running security sanitize scan..."
"${REPO_ROOT}/scripts/sanitize.sh"

echo "========================================================"
echo "  ✅ Upstream synchronization complete!                 "
echo "========================================================"
