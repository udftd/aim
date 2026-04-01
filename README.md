# AIM — AI Memory

> 多 AI Coding Agent 的记忆管理系统

在 Claude Code、Cursor、Cline、Codex 等多种 AI 工具之间共享项目上下文，让每次会话都能接续上次工作，不再重复解释背景。

## 定位

现代开发中往往同时使用多个 AI Coding Agent：Claude Code 做复杂重构，Cursor 做日常编辑，Codex 跑批量任务。但这些工具各自独立，没有共享记忆——每次切换都要重新交代背景，每次新会话都从零开始。

**AIM 解决这个问题**：在 `~/.ai-memory/` 维护一套结构化 Markdown 文件，为所有 AI 工具提供统一的项目记忆。核心设计原则：

- **纯 Markdown**，所有模型通用，无供应商锁定
- **分层加载**，按需注入上下文，token 开销最小化（默认 ~800 tok）
- **工具无关**，同一份记忆桥接到 Claude Code、Cursor、Cline、Copilot 等

## 快速开始

```bash
# 1. 全局初始化（只需一次）
bash aim-init.sh

# 2. 加入 PATH
echo 'export PATH="$HOME/.ai-memory/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc

# 3. 为项目创建记忆
aim-init.sh my-app              # 开发模式
aim-init.sh my-app --study      # 研读/接手已有项目
aim-init.sh my-app --large      # 大型项目（含子模块支持）

# 4. 在项目目录生成 AI 工具桥接文件
cd ~/codes/my-app
aim-bridge.sh my-app . --tools all
```

完成后，打开任意 AI 工具，它会自动读取项目上下文。

## 工作流

```
首次:  aim-init.sh → aim-bridge.sh → 开始工作
日常:  AI 自动加载记忆 → 工作 → "更新 handoff" → aim-end.sh
切换:  AI-A 写 handoff → AI-B 读 → 无缝接续
Web:   aim-start.sh → 复制到剪贴板 → 粘贴给网页版 AI
```

## 记忆文件结构

```
~/.ai-memory/
├── global/
│   ├── USER.md          身份与 AI 协作偏好
│   ├── TOOLS.md         工具链与环境
│   └── PATTERNS.md      跨项目经验积累
└── projects/<name>/
    ├── HANDOFF.md        当前工作快照（每次 session 更新，< 40 行）
    ├── TODO.md           任务追踪
    ├── MEMORY.md         长期记忆：架构、技术选型、教训
    ├── DECISIONS.md      架构决策记录（ADR 格式）
    ├── FEATURES.md       特性追踪（可选）
    ├── sessions/
    │   └── SESSION-LOG.md   滚动日志（保留最近 10 条）
    └── modules/          子模块上下文（--large 模式）
        └── <mod>/CONTEXT.md
```

## 上下文加载

`CLAUDE.local.md` 默认只加载 HANDOFF.md + TODO.md（~800 tok），保持 context 精简。

模块上下文由 `/aim-module` skill 按需切换加载。其他记忆文件（MEMORY.md、DECISIONS.md 等）AI 可按需 Read，无需预加载。

## 支持的 AI 工具

| 工具 | 桥接方式 |
|------|---------|
| Claude Code | `CLAUDE.local.md`（`@path` 自动 import） |
| Codex CLI | `AGENTS.override.md` |
| Cline / Roo Code | `.clinerules/` / `.roo/rules/`（symlink） |
| Cursor | `.cursor/rules/*.mdc`（symlink） |
| GitHub Copilot | `.github/copilot-instructions.md` |
| 网页版 AI（ChatGPT/Kimi/DeepSeek） | `aim-start.sh` 输出到剪贴板 |
| 自建 API | `aim_loader.py` 注入 system prompt |

## 全部命令

```bash
aim-init.sh <project> [--study] [--large]   # 初始化项目记忆
aim-bridge.sh <project> [path] [--tools x]  # 生成 AI 工具桥接文件
aim-start.sh <project> [mod] [--with x]     # 上下文输出到剪贴板
aim-end.sh <project>                        # session 结束健康检查
aim-archive.sh <project>                    # 归档溢出的 session 日志
aim-search.sh <query> [project]             # 搜索记忆文件
aim-add-module.sh <project> <module>        # 添加子模块
```

## 环境变量

```bash
AI_MEMORY_ROOT=~/.ai-memory   # 覆盖默认存储路径
```

## TODO

- [x] **升级机制**：已实现 `aim-upgrade.sh`，支持 `--check`、`--force`、`--source`。
- [x] **Skill 跨工具兼容**：AIM skills 兼容 Codex / Claude 双桥接场景。

## 依赖

- bash 4+（macOS 需 `brew install bash`）
- 标准 Unix 工具（grep、awk、sed）
- `rg`（ripgrep）可选，用于加速搜索
