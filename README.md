# Claude Code AIO (All-In-One)

[![Auto-Sync Upstreams](https://github.com/oaichu/claude-code-aio/actions/workflows/upstream-sync.yml/badge.svg)](https://github.com/oaichu/claude-code-aio/actions/workflows/upstream-sync.yml)
[![CI Validation & Security Scan](https://github.com/oaichu/claude-code-aio/actions/workflows/validate.yml/badge.svg)](https://github.com/oaichu/claude-code-aio/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Kho cấu hình, bộ kỹ năng (Skills), đặc vụ (Agents), quy tắc (Rules) và MCP toàn diện cho **Claude Code** và các Agent CLI (`claude`, `opencode`, `gemini`, `codex`, `aider`). Tự động đồng bộ bản mới nhất từ các nguồn upstream hàng ngày.

---

## 🌟 Tính năng nổi bật (Key Features)

- **116 Curated Skills**: Tinh lọc từ các hệ sinh thái hàng đầu:
  - 🎮 **Game Studio** (73 skills): Full lifecycle làm game từ Godot, Unity, Bevy, Game Design Docs đến Gameplay Mechanics.
  - ⚡ **Superpowers** (14 skills): TDD, Systematic Debugging, Worktree isolation, Branch finishing.
  - 🧠 **Advanced Reasoning & Thinking** (5 skills): Council multi-perspective, Recursive decision ledger, Agent self-evaluation, Intent-driven development.
  - 🎨 **Modern Frontend UI/UX** (3 skills): Phân tách 3 tầng (Design Tokens, Styling Systems, Interactive Animations).
  - 🔍 **Live Research & Docs**: Context7 live documentation lookup (không đoán mò API), deep search.
  - 🗄️ **Backend, Database & DevOps**: Postgres, Prisma, Redis, Security scanning, GitHub Operations.
- **118 Specialist Agents**: 50 Game Studio specialists, Chief Architect, Security Auditor, Visual QA Reviewer...
- **Multi-Harness Bridging**: Đồng bộ qua Ponytail & Autoharness cho `claude`, `opencode`, `gemini`, `codex`, `aider`.
- **Elite Core MCP (Context Economy)**: Chỉ 3 MCP cốt lõi (`codegraph`, `puppeteer`, `context7`), tiết kiệm >15.000 tokens mỗi turn, loại bỏ 100% token bloat và tool confusion.
- **🔄 Auto-Sync Upstreams**: GitHub Actions tự động quét và hợp nhất cập nhật từ các repo gốc hàng ngày vào branch `main`.

---

## 🚀 Cài đặt & Khôi phục nhanh (Quick Restore)

### Cách 1: Clone và chạy Installer
```bash
git clone https://github.com/oaichu/claude-code-aio.git
cd claude-code-aio
./scripts/install.sh
```

Installer sẽ:
1. Tự động sao lưu toàn bộ cấu hình cũ tại `~/.claude.backup.<timestamp>/`.
2. Nạp toàn bộ 116 Skills, 118 Agents và Rules vào `~/.claude/`.
3. Thiết lập các plugin cần thiết và cấu hình bộ 3 MCP tinh gọn (`codegraph`, `puppeteer`, `context7`).
4. Đồng bộ MCP sang Gemini/Antigravity và OpenCode nếu có.

---

## 🔄 Cơ chế tự động cập nhật từ nguồn Upstream

Repository này được tích hợp hệ thống **Upstream Sync Engine**:
- **Tự động trên GitHub**: GitHub Actions workflow ([`.github/workflows/upstream-sync.yml`](.github/workflows/upstream-sync.yml)) chạy mỗi ngày lúc 02:00 UTC (hoặc bấm chạy thủ công qua `Run workflow`).
- **Nguồn upstream đồng bộ**:
  - `Donchitos/Claude-Code-Game-Studios`
  - `obra/superpowers`
  - `DietrichGebert/ponytail`
  - `tigerless-labs/autoharness`
- **Chạy cập nhật thủ công trên máy cục bộ bất kỳ lúc nào**:
  ```bash
  ./scripts/sync-upstream.sh
  ```

---

## 💾 Sao lưu thay đổi cá nhân vào Repo (Local Backup)

Khi bạn thêm hoặc chỉnh sửa skills/agents/rules trên máy và muốn cập nhật lại vào repo:
```bash
./scripts/backup.sh
git add .
git commit -m "feat: update my custom skills & configs"
git push origin main
```
*Script tự động quét kiểm tra bảo mật ([`scripts/sanitize.sh`](scripts/sanitize.sh)), ngăn chặn hoàn toàn việc vô tình đẩy API key hay token lên GitHub.*

---

## 📂 Cấu trúc Repository

```text
claude-code-aio/
├── .github/
│   └── workflows/
│       ├── upstream-sync.yml    # Auto-sync upstream daily cron
│       └── validate.yml         # CI security scan & syntax check
├── agents/                      # 118 Specialist Agents (.md)
├── configs/                     # Template cấu hình sạch (0 secret)
│   ├── claude.json.template
│   ├── settings.json.template
│   ├── opencode.json.template
│   └── gemini-mcp.json.template
├── rules/                       # Hệ thống Rules & SOPs
├── scripts/
│   ├── backup.sh                # Export & sanitize local ~/.claude
│   ├── install.sh               # Safe 1-line installer / restorer
│   ├── sync-upstream.sh         # Pulls & merges upstream repos
│   └── sanitize.sh              # Scanner chống rò rỉ token/key
├── skills/                      # 116 Curated Skills
├── .env.example                 # Mẫu biến môi trường
└── README.md
```

---

## 🛡️ Bảo mật (Security)

- **Zero Secret Guarantee**: Không chứa bất kỳ API key, credential hay token nào trong repo.
- Mọi biến nhạy cảm được cấu hình thông qua file `.env` hoặc biến môi trường hệ thống (`ANTHROPIC_API_KEY`, `GH_TOKEN`).

---

## 📄 License

Phát hành theo giấy phép [MIT](LICENSE).
