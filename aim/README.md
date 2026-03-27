# AIM — AI Memory System

> 跨 AI 工具的共享记忆。纯 Markdown，所有模型通用，token 经济优先。

## 快速开始

```bash
# 1. 解压后初始化
bash aim-init.sh

# 2. 创建项目 (三种模式)
aim-init.sh my-app                       # 开发: 你要开发这个项目
aim-init.sh kubernetes --study           # 研读: 你要理解已有项目
aim-init.sh kubernetes --study --large   # 研读大型项目 (含 modules/)

# 3. 在项目代码目录生成桥接
cd ~/codes/my-app
aim-bridge.sh my-app . --tools all

# 4. 加到 PATH
echo 'export PATH="$HOME/.ai-memory/bin:$PATH"' >> ~/.zshrc
```

## 两种场景

### 开发项目

你在写代码、修 bug、加功能。AIM 跨 AI 工具保持工作连续性。

```bash
aim-init.sh my-app
cd ~/codes/my-app && aim-bridge.sh my-app . --tools all
# → 打开 AI 工具直接工作 → 结束说 "更新 handoff"
```

### 研读/接手项目

拿到已有项目，让 AI 帮你阅读和理解代码。

```bash
aim-init.sh kubernetes --study --large
cd ~/codes/kubernetes && aim-bridge.sh kubernetes . --tools all

# 第一个 session prompt:
# "请阅读项目目录结构和 README，帮我梳理模块划分和架构。然后更新 handoff。"

# AI 帮你理清结构后添加子模块:
aim-add-module.sh kubernetes api-server
aim-add-module.sh kubernetes scheduler
```

## 完整流程

```
aim-init.sh   →   aim-bridge.sh   →   AI Session   →   "更新 handoff"
创建记忆项目       连接到 AI 工具       实际工作          交接状态
(只需一次)         (只需一次)          (日常)            (每次)
```

## 目录结构

```
~/.ai-memory/
├── global/
│   ├── USER.md              身份 & 偏好
│   ├── TOOLS.md             工具链 & 环境
│   └── PATTERNS.md          跨项目经验
├── projects/<name>/
│   ├── PROJECT.md           项目元信息
│   ├── HANDOFF.md           交接快照 (< 40 行, 每次覆盖)
│   ├── TODO.md              任务追踪
│   ├── MEMORY.md            长期记忆 (Active / Archived)
│   ├── DECISIONS.md         架构决策记录
│   ├── FEATURES.md          特性跟踪 (可选)
│   ├── sessions/
│   │   ├── SESSION-LOG.md   滚动摘要 (最近 10 条)
│   │   └── archive/         月度归档
│   └── modules/             子模块 (--large 时创建)
│       ├── _INDEX.md
│       └── <mod>/CONTEXT.md
└── bin/                     脚本
```

## 分层加载 (token 经济性)

```
L0  HANDOFF + TODO              ~800 tok   每次 (默认)
L1  modules/<mod>/CONTEXT.md    ~500 tok   涉及模块时
L2  MEMORY.md Active            ~2000 tok  需要背景时
L3  DECISIONS / FEATURES        ~1000 tok  架构讨论时
L4  USER / TOOLS                ~400 tok   切换 AI 时
```

默认只加载 L0。CLAUDE.local.md 里用 `#` 注释控制层级。

每 session AIM 开销: ~$0.014 (Sonnet) | 日均 ~$0.075 | 占 Claude Code 日均 ~1%

## 工具桥接

| 工具 | 桥接文件 | 方式 |
|------|---------|------|
| Claude Code | CLAUDE.local.md | @import 自动 |
| Codex CLI | AGENTS.local.md | 引用 |
| Cline / Roo Code | .clinerules / .roo/rules | symlink 自动 |
| Cursor | .cursor/rules/*.mdc | symlink 自动 |
| Copilot | .github/copilot-instructions.md | symlink |
| Web AI (Kimi/DeepSeek/GPT) | aim-start.sh | 剪贴板粘贴 |
| 自建 API | aim_loader.py | system prompt |

## 全部脚本

```bash
aim-init.sh <project> [--study] [--large]   # 初始化
aim-bridge.sh <project> [path] [--tools x]  # 桥接
aim-start.sh <project> [mod] [--with x]     # 上下文到剪贴板
aim-end.sh <project>                        # 结束检查
aim-archive.sh <project>                    # 归档溢出 session
aim-search.sh <query> [project]             # 搜索记忆
aim-add-module.sh <project> <module>        # 添加子模块
```

## 生命周期

```
HANDOFF.md       每次覆盖 (即时快照)
SESSION-LOG.md   滚动 10 条 → aim-archive.sh → archive/YYYY-MM.md
MEMORY Active    < 200 行 → 过时移 Archived
PATTERNS.md      跨项目通用经验
```

## 搜索兼容

```
L0  grep/rg           aim-search.sh (开箱即用)
L1  SQLite FTS         memsearch index ~/.ai-memory/ (可选)
L2  向量语义           memsearch --hybrid (可选)
```

文件约定: `---` 分隔条目 + YAML frontmatter + `#tag` 内联标签 = 三级搜索都兼容
