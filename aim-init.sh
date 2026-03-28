#!/bin/bash
# AIM — aim-init.sh
#
# aim-init.sh                          初始化 ~/.ai-memory
# aim-init.sh <project>                创建项目 (开发模式)
# aim-init.sh <project> --study        创建项目 (研读/接手模式)
# aim-init.sh <project> --large        大型项目 (含 modules/)
# aim-init.sh <project> --study --large 研读大型项目
#
# 开发模式: 你要从头或继续开发这个项目
# 研读模式: 你要阅读、理解、学习一个已有项目的代码

set -e
AIM="${AI_MEMORY_ROOT:-$HOME/.ai-memory}"
G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' R='\033[0;31m' N='\033[0m'

init_global() {
    echo -e "${C}🧠 AIM init: $AIM${N}"
    mkdir -p "$AIM"/{global,projects,bin}

    [ -f "$AIM/global/USER.md" ] || cat > "$AIM/global/USER.md" << 'E'
# User Profile
## 身份
- 名字: [TODO]
- 角色: [TODO]
- 主力语言: [TODO]
## 环境
- OS: [TODO]
- 开发目录: [TODO]
- 编辑器: [TODO]
## AI 协作偏好
- 回复语言: [TODO]
- 回复风格: [TODO]
- 解释深度: [TODO]
## 技术背景
- [TODO]
E

    [ -f "$AIM/global/TOOLS.md" ] || cat > "$AIM/global/TOOLS.md" << 'E'
# Tool Chain
## AI 工具
- [TODO]
## 开发工具
- [TODO]
E

    [ -f "$AIM/global/PATTERNS.md" ] || cat > "$AIM/global/PATTERNS.md" << 'E'
# Patterns & Anti-patterns
## 好的模式
(待积累)
## 反模式
(待积累)
## AI 协作经验
(待积累)
E

    local SD; SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    for s in "$SD"/aim-*.sh; do
        [ -f "$s" ] || continue
        [ "$(basename "$s")" = "aim-upgrade.sh" ] && continue
        cp "$s" "$AIM/bin/$(basename "$s")" && chmod +x "$AIM/bin/$(basename "$s")"
    done
    [ -f "$SD/aim_loader.py" ] && cp "$SD/aim_loader.py" "$AIM/bin/aim_loader.py"

    cat > "$AIM/.aim-meta" << EOF
version=$(cat "$SD/VERSION" 2>/dev/null || echo "0.0")
source=$SD
installed=$(date +%Y-%m-%d)
EOF

    echo -e "${G}✅ 全局系统已初始化${N}"
    echo "  export PATH=\"$AIM/bin:\$PATH\""
}

init_project() {
    local P="$1" MODE="$2" LARGE="$3"
    local PD="$AIM/projects/$P"
    local IS_STUDY=false
    [ "$MODE" = "study" ] && IS_STUDY=true

    if $IS_STUDY; then
        echo -e "${C}📖 创建项目 (研读模式): $P${N}"
    else
        echo -e "${C}📁 创建项目 (开发模式): $P${N}"
    fi

    mkdir -p "$PD/sessions/archive"

    # ── PROJECT.md ──
    cat > "$PD/PROJECT.md" << EOF
# Project: $P

## 基本信息
- **一句话描述**: [TODO]
- **代码路径**: [TODO: 如 ~/codes/$P]
- **技术栈**: [TODO]
- **项目规模**: [small/medium/large]
- **我的角色**: [$(if $IS_STUDY; then echo "研读学习"; else echo "开发"; fi)]

## 项目已有的 AI 配置
- CLAUDE.md: [有/无]
- AGENTS.md: [有/无]
- .clinerules: [有/无]

## Build & Run
- Install: \`[TODO]\`
- Dev: \`[TODO]\`
- Test: \`[TODO]\`

## 快速上下文
[TODO: 2-3 句话]
EOF

    # ── HANDOFF.md (根据模式不同) ──
    if $IS_STUDY; then
        cat > "$PD/HANDOFF.md" << EOF
# Handoff — $P

> updated: $(date +%Y-%m-%d) | by: init | module: N/A

## State: 开始研读项目

## Progress
- [ ] 了解项目整体用途和架构
- [ ] 理清目录结构和模块划分
- [ ] 跑通 build 和 test
- [ ] 阅读核心模块代码
- [ ] 填写 MEMORY.md 核心认知

## Context (max 5)
(首次 session: 让 AI 帮你梳理项目结构)

## Failed (max 3)
(无)

## Open (max 3)
(无)

## Warnings (max 3)
(无)
EOF
    else
        cat > "$PD/HANDOFF.md" << EOF
# Handoff — $P

> updated: $(date +%Y-%m-%d) | by: init | module: N/A

## State: 刚初始化

## Progress
- [ ] 填写 PROJECT.md
- [ ] 填写 MEMORY.md
- [ ] 开始第一个任务

## Context (max 5)
(首次 session 待填写)

## Failed (max 3)
(无)

## Open (max 3)
(无)

## Warnings (max 3)
(无)
EOF
    fi

    # ── TODO.md (根据模式不同) ──
    if $IS_STUDY; then
        cat > "$PD/TODO.md" << EOF
# Tasks — $P

## 🎯 当前目标
理解项目架构和核心代码

## P0
- [ ] 让 AI 帮梳理项目目录结构和模块划分
- [ ] 理解 build 流程，跑通 build + test
- [ ] 阅读 README / 项目文档

## P1
- [ ] 深入阅读核心模块代码
- [ ] 理清核心数据流 / 请求路径
- [ ] 记录关键设计模式和约定到 MEMORY.md

## P2
- [ ] 画架构图 (可以让 AI 帮忙)
- [ ] 对比自己的理解和文档是否一致

## Done (keep 5)
(无)

## Ideas
(待添加)
EOF
    else
        cat > "$PD/TODO.md" << EOF
# Tasks — $P

## 🎯 当前目标
[TODO]

## P0
- [ ] 完善 AIM 项目文件

## P1
(待添加)

## Done (keep 5)
(无)

## Ideas
(待添加)
EOF
    fi

    # ── MEMORY.md (研读模式有引导结构) ──
    if $IS_STUDY; then
        cat > "$PD/MEMORY.md" << EOF
# Long-Term Memory — $P

> 研读笔记。Active < 200 行。

## Active

### 项目是什么
- [TODO: 一句话描述项目用途]
- [TODO: 面向什么用户/场景]

### 架构概览
- [TODO: 整体架构模式，如微服务/单体/模块化]
- [TODO: 核心组件和它们的关系]

### 技术栈
- [TODO: 语言、框架、关键依赖]

### 目录结构速记
- [TODO: 关键目录和它们的职责]

### 核心数据流
- [TODO: 主要的请求/数据处理路径]

### 设计模式 & 约定
- [TODO: 项目中反复使用的模式]

### 我的疑问
- [TODO: 还没搞清楚的点]

### 踩坑
(待积累)

---

## Archived
(过时的认知)
EOF
    else
        cat > "$PD/MEMORY.md" << EOF
# Long-Term Memory — $P

> Active < 200 行。过时的移 Archived。

## Active

### 核心认知
- [TODO]

### 技术选型
- [TODO]

### 经验教训
(待积累)

### 重要约定
(待积累)

---

## Archived
(过时但保留)
EOF
    fi

    # ── DECISIONS.md ──
    cat > "$PD/DECISIONS.md" << 'EOF'
# Architecture Decision Records

(通过 AI session 逐渐积累)
EOF

    # ── SESSION-LOG.md ──
    cat > "$PD/sessions/SESSION-LOG.md" << EOF
# Session Log — $P

(等待第一个 session)
EOF

    # ── 大型项目 ──
    if [ "$LARGE" = "true" ]; then
        mkdir -p "$PD/modules"
        cat > "$PD/modules/_INDEX.md" << EOF
# Module Index — $P

## 活跃模块
| 模块 | 路径提示 | 熟悉度 | 最近 |
|------|---------|--------|------|

## 模块间关系
(待填写)
EOF
        echo -e "  ${G}✓ modules/${N}"
    fi

    echo -e "${G}✅ $PD${N}"
    find "$PD" -type f | sort
    echo ""

    # ── 使用提示 ──
    if $IS_STUDY; then
        echo -e "${Y}📖 研读模式使用提示:${N}"
        echo "  1. 填写 PROJECT.md 的代码路径和技术栈"
        echo "  2. 在项目目录运行: aim-bridge.sh $P . --tools all"
        echo "  3. 打开 AI 工具，让它帮你梳理项目结构:"
        echo ""
        echo "     \"请阅读项目目录结构和 README，"
        echo "      帮我梳理这个项目的模块划分和架构。"
        echo "      然后更新 handoff。\""
        echo ""
        if [ "$LARGE" = "true" ]; then
            echo "  4. 理清模块后，添加子模块:"
            echo "     aim-add-module.sh $P <module-name>"
        fi
    else
        echo -e "${Y}下一步:${N}"
        echo "  1. 填写 $PD/PROJECT.md"
        echo "  2. aim-bridge.sh $P <项目路径> --tools all"
    fi
}

# ── 主逻辑 ──
if [ -z "$1" ]; then
    [ -d "$AIM/global" ] && echo -e "${Y}⚠️  已存在，跳过已有文件${N}"
    init_global
else
    P="$1"; shift
    MODE="dev"; LARGE="false"
    while [[ $# -gt 0 ]]; do
        case $1 in
            --study) MODE="study"; shift;;
            --large) LARGE="true"; shift;;
            *) shift;;
        esac
    done

    [ ! -d "$AIM/global" ] && init_global && echo ""
    [ -d "$AIM/projects/$P" ] && echo -e "${R}❌ 已存在: $AIM/projects/$P${N}" && exit 1
    init_project "$P" "$MODE" "$LARGE"
fi
