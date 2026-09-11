#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CLAUDE_JSON="${HOME}/.claude.json"
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo "========================================================"
echo "          Claude Code AIO — Installer & Restorer        "
echo "========================================================"

# 1. Backup existing configuration
if [ -d "${CLAUDE_DIR}" ]; then
    echo "==> Creating safety backup at ${HOME}/.claude.backup.${BACKUP_TIMESTAMP}..."
    mkdir -p "${HOME}/.claude.backup.${BACKUP_TIMESTAMP}"
    [ -d "${CLAUDE_DIR}/skills" ] && cp -r "${CLAUDE_DIR}/skills" "${HOME}/.claude.backup.${BACKUP_TIMESTAMP}/" || true
    [ -d "${CLAUDE_DIR}/agents" ] && cp -r "${CLAUDE_DIR}/agents" "${HOME}/.claude.backup.${BACKUP_TIMESTAMP}/" || true
    [ -d "${CLAUDE_DIR}/rules" ] && cp -r "${CLAUDE_DIR}/rules" "${HOME}/.claude.backup.${BACKUP_TIMESTAMP}/" || true
    [ -f "${CLAUDE_DIR}/settings.json" ] && cp "${CLAUDE_DIR}/settings.json" "${HOME}/.claude.backup.${BACKUP_TIMESTAMP}/" || true
    [ -f "${CLAUDE_JSON}" ] && cp "${CLAUDE_JSON}" "${HOME}/.claude.backup.${BACKUP_TIMESTAMP}/.claude.json" || true
fi

# 2. Deploy directory structure
echo "==> Deploying Skills, Agents, and Rules..."
mkdir -p "${CLAUDE_DIR}/skills" "${CLAUDE_DIR}/agents" "${CLAUDE_DIR}/rules" "${CLAUDE_DIR}/backups"

# Sync skills
if [ -d "${REPO_ROOT}/skills" ]; then
    rsync -av --delete "${REPO_ROOT}/skills/" "${CLAUDE_DIR}/skills/"
    SKILL_COUNT=$(find "${CLAUDE_DIR}/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)
    echo "   -> Synced ${SKILL_COUNT} skills"
fi

# Sync agents
if [ -d "${REPO_ROOT}/agents" ]; then
    rsync -av --delete "${REPO_ROOT}/agents/" "${CLAUDE_DIR}/agents/"
    AGENT_COUNT=$(find "${CLAUDE_DIR}/agents" -mindepth 1 -maxdepth 1 -type f -name "*.md" | wc -l)
    echo "   -> Synced ${AGENT_COUNT} agents"
fi

# Sync rules
if [ -d "${REPO_ROOT}/rules" ]; then
    rsync -av "${REPO_ROOT}/rules/" "${CLAUDE_DIR}/rules/"
    RULE_COUNT=$(find "${CLAUDE_DIR}/rules" -mindepth 1 -type f -name "*.md" | wc -l)
    echo "   -> Synced ${RULE_COUNT} rules"
fi

# 3. Configure MCP Servers in ~/.claude.json
echo "==> Configuring Elite MCP Servers (codegraph, puppeteer, context7)..."
if [ ! -f "${CLAUDE_JSON}" ]; then
    cp "${REPO_ROOT}/configs/claude.json.template" "${CLAUDE_JSON}"
else
    python3 -c '
import json, os

claude_json_path = os.path.expanduser("~/.claude.json")
try:
    with open(claude_json_path, "r") as f:
        data = json.load(f)
except Exception:
    data = {}

if "mcpServers" not in data:
    data["mcpServers"] = {}

# Ensure elite MCP servers
data["mcpServers"]["codegraph"] = {
    "type": "stdio",
    "command": "codegraph",
    "args": ["serve", "--mcp"]
}
data["mcpServers"]["puppeteer"] = {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
}
data["mcpServers"]["context7"] = {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp@latest"]
}

with open(claude_json_path, "w") as f:
    json.dump(data, f, indent=2)
'
fi

# 4. Configure settings.json
echo "==> Configuring plugins and settings in ~/.claude/settings.json..."
if [ ! -f "${CLAUDE_DIR}/settings.json" ]; then
    cp "${REPO_ROOT}/configs/settings.json.template" "${CLAUDE_DIR}/settings.json"
else
    python3 -c '
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")
try:
    with open(settings_path, "r") as f:
        data = json.load(f)
except Exception:
    data = {}

# Merge plugins
if "enabledPlugins" not in data:
    data["enabledPlugins"] = {}

plugins = [
    "claude-mem@thedotmack",
    "ui-design@claude-code-workflows",
    "typescript-lsp@claude-plugins-official",
    "ponytail@ponytail",
    "autoharness@autoharness",
    "superpowers@superpowers",
    "frontend-design@claude-plugins-official"
]
for p in plugins:
    data["enabledPlugins"][p] = True

# Merge marketplaces
if "extraKnownMarketplaces" not in data:
    data["extraKnownMarketplaces"] = {}

marketplaces = {
    "claude-code-workflows": {"source": {"source": "github", "repo": "wshobson/agents"}},
    "thedotmack": {"source": {"source": "github", "repo": "thedotmack/claude-mem"}},
    "ponytail": {"source": {"source": "github", "repo": "DietrichGebert/ponytail"}},
    "autoharness": {"source": {"source": "github", "repo": "tigerless-labs/autoharness"}},
    "superpowers": {"source": {"source": "github", "repo": "obra/superpowers"}}
}
for k, v in marketplaces.items():
    if k not in data["extraKnownMarketplaces"]:
        data["extraKnownMarketplaces"][k] = v

with open(settings_path, "w") as f:
    json.dump(data, f, indent=2)
'
fi

# 5. Sync multi-agent harnesses if installed
# Gemini / Antigravity
GEMINI_MCP="${HOME}/.gemini/config/mcp_config.json"
if [ -d "${HOME}/.gemini" ]; then
    echo "==> Syncing MCP to Gemini / Antigravity..."
    mkdir -p "${HOME}/.gemini/config"
    python3 -c '
import json, os
p = os.path.expanduser("~/.gemini/config/mcp_config.json")
try:
    with open(p, "r") as f: d = json.load(f)
except Exception: d = {}
if "mcpServers" not in d: d["mcpServers"] = {}
d["mcpServers"]["puppeteer"] = {"command": "npx", "args": ["-y", "@modelcontextprotocol/server-puppeteer"]}
d["mcpServers"]["context7"] = {"command": "npx", "args": ["-y", "@upstash/context7-mcp@latest"]}
with open(p, "w") as f: json.dump(d, f, indent=2)
'
fi

# OpenCode
OPENCODE_JSON="${HOME}/.config/opencode/opencode.json"
if [ -d "${HOME}/.config/opencode" ]; then
    echo "==> Syncing MCP to OpenCode..."
    python3 -c '
import json, os
p = os.path.expanduser("~/.config/opencode/opencode.json")
try:
    with open(p, "r") as f: d = json.load(f)
except Exception: d = {}
if "mcp" not in d: d["mcp"] = {}
d["mcp"]["puppeteer"] = {"type": "local", "command": ["npx", "-y", "@modelcontextprotocol/server-puppeteer"]}
d["mcp"]["context7"] = {"type": "local", "command": ["npx", "-y", "@upstash/context7-mcp@latest"]}
with open(p, "w") as f: json.dump(d, f, indent=2)
'
fi

echo "========================================================"
echo "  ✅ Claude Code AIO successfully installed & restored! "
echo "========================================================"
