# AIM — 全部文件模板

> 📖 = 研读模式 (`--study`)　🔧 = 开发模式　无标记 = 通用

---

## global/USER.md

```markdown
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
```

## global/TOOLS.md

```markdown
# Tool Chain
## AI 工具
- [TODO]
## 开发工具
- [TODO]
## 基础设施
- [TODO]
```

## global/PATTERNS.md

```markdown
# Patterns & Anti-patterns
## 好的模式
(待积累)
## 反模式
(待积累)
## AI 协作经验
(待积累)
```

---

## projects/xxx/PROJECT.md

```markdown
# Project: [项目名]
- **一句话描述**: [TODO]
- **代码路径**: [TODO]
- **技术栈**: [TODO]
- **项目规模**: [small/medium/large]
- **我的角色**: [开发 / 研读学习 / 运维]
## 项目已有的 AI 配置
- CLAUDE.md: [有/无]
- AGENTS.md: [有/无]
- .clinerules: [有/无]
## Build & Run
- Install: `[TODO]`
- Dev: `[TODO]`
- Test: `[TODO]`
## 快速上下文
[2-3 句话]
```

---

## projects/xxx/HANDOFF.md

> **约束: < 40 行, < 600 tokens。只写状态，不写过程。**

### 🔧 开发模式

```markdown
# Handoff — [项目名]

> updated: YYYY-MM-DD | by: init | module: N/A

## State: 刚初始化

## Progress
- [ ] 填写 PROJECT.md
- [ ] 填写 MEMORY.md
- [ ] 开始第一个任务

## Context (max 5)
## Failed (max 3)
## Open (max 3)
## Warnings (max 3)
```

### 📖 研读模式

```markdown
# Handoff — [项目名]

> updated: YYYY-MM-DD | by: init | module: N/A

## State: 开始研读项目

## Progress
- [ ] 了解项目整体用途和架构
- [ ] 理清目录结构和模块划分
- [ ] 跑通 build 和 test
- [ ] 阅读核心模块代码
- [ ] 填写 MEMORY.md 核心认知

## Context (max 5)
(让 AI 帮你梳理项目结构)
## Failed (max 3)
## Open (max 3)
## Warnings (max 3)
```

### 日常更新后的样子

```markdown
# Handoff — kubernetes

> updated: 2026-03-22 14:30 | by: claude-code | module: api-server

## State: 调试准入控制链

## Progress
- [x] 定位 webhook timeout 问题
- [x] 修复 timeout 配置
- [ ] 更新 e2e 测试 ←
- [ ] PR review

## Context (max 5)
- webhook timeout 默认 10s，大集群需 30s
- 决定用 ValidatingAdmissionPolicy 替换旧 webhook
- PR #1234 已提交

## Failed (max 3)
- 直接改 apiserver 参数: 不生效，需改 webhook config

## Open (max 3)
1. e2e 测试在 CI 跑不过 — 可能超时太短

## Warnings (max 3)
- 不要碰 admission/plugin 目录，正在重构
```

---

## projects/xxx/TODO.md

### 🔧 开发模式

```markdown
# Tasks — [项目名]
## 🎯 当前目标
[TODO]
## P0
- [ ] [任务] `owner:[AI/Human]`
## P1
(待添加)
## Done (keep 5)
(无)
## Ideas
(待添加)
```

### 📖 研读模式

```markdown
# Tasks — [项目名]
## 🎯 当前目标
理解项目架构和核心代码
## P0
- [ ] 让 AI 梳理目录结构和模块划分
- [ ] 跑通 build + test
- [ ] 阅读 README / 项目文档
## P1
- [ ] 深入核心模块代码
- [ ] 理清核心数据流
- [ ] 记录设计模式到 MEMORY.md
## P2
- [ ] 画架构图
## Done (keep 5)
(无)
## Ideas
(待添加)
```

---

## projects/xxx/MEMORY.md

### 🔧 开发模式

```markdown
# Long-Term Memory — [项目名]
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
```

### 📖 研读模式

```markdown
# Long-Term Memory — [项目名]
> 研读笔记。Active < 200 行。

## Active
### 项目是什么
- [TODO: 用途和目标用户]
### 架构概览
- [TODO: 架构模式、核心组件关系]
### 技术栈
- [TODO: 语言、框架、关键依赖]
### 目录结构速记
- [TODO: 关键目录职责]
### 核心数据流
- [TODO: 主要请求/数据处理路径]
### 设计模式 & 约定
- [TODO: 项目反复使用的模式]
### 我的疑问
- [TODO: 还没搞清楚的点]
### 踩坑
(待积累)

---
## Archived
(过时的认知)
```

---

## projects/xxx/DECISIONS.md

```markdown
# Architecture Decision Records

---
id: adr-001
date: YYYY-MM-DD
status: accepted
---
## ADR-001: [标题]
**上下文**: [为什么]
**决定**: [选了什么]
**备选**: [没选什么]
**后果**: [影响]
```

---

## projects/xxx/FEATURES.md (可选)

```markdown
# Feature Tracker — [项目名]
> 每 session 推进 1-3 个。
## Stats: 0 done / 0 total
### [类别]
- [ ] F001: [特性] `status:todo`
- [x] F002: [特性] `status:done` `session:YYYY-MM-DD`
```

---

## sessions/SESSION-LOG.md

每条 ≤ 5 行。保留 10 条。溢出 → `aim-archive.sh` → archive/YYYY-MM.md。

```markdown
# Session Log — [项目名]

---
s: 2026-03-22-1400
ai: claude-code
mod: api-server
---
调试准入控制 webhook 超时 → 修复 timeout 配置 → PR #1234
决策: ValidatingAdmissionPolicy 替换旧 webhook
教训: webhook timeout 默认 10s 大集群不够 #pitfall
```

---

## modules/_INDEX.md

```markdown
# Module Index — [项目名]
## 活跃模块
| 模块 | 路径提示 | 熟悉度 | 最近 |
|------|---------|--------|------|
## 模块间关系
- [A] → [B]: [关系]
```

## modules/xxx/CONTEXT.md

```markdown
---
project: [项目名]
module: [模块名]
tags: []
---
# Module: [模块名]
## 是什么
[一段话]
## 关键区域
- [能力描述，非路径]
## 我的理解
- [清楚/不清楚]
## 踩坑
(待积累)
## 关联
- 依赖: [谁]
- 被依赖: [谁]
```

---

## 桥接文件

### CLAUDE.local.md (Claude Code)

```markdown
# CLAUDE.local.md — AIM Bridge
# ── L0: 每次 (~800 tok) ──
@~/.ai-memory/projects/<PROJECT>/HANDOFF.md
@~/.ai-memory/projects/<PROJECT>/TODO.md
# ── L1: 模块 (切换时改) ──
<!-- inactive import: ~/.ai-memory/projects/<PROJECT>/modules/<MOD>/CONTEXT.md -->
# ── L2: 背景 ──
<!-- inactive import: ~/.ai-memory/projects/<PROJECT>/MEMORY.md -->
# ── L3: 架构 ──
<!-- inactive import: ~/.ai-memory/projects/<PROJECT>/DECISIONS.md -->
# ── L4: 切换 AI ──
<!-- inactive import: ~/.ai-memory/global/USER.md -->
<!-- inactive import: ~/.ai-memory/global/TOOLS.md -->
# Session 结束说 "更新 handoff"
```

### AGENTS.override.md (Codex CLI)

```markdown
# AGENTS.override.md — AIM Bridge
> generated from ~/.ai-memory/projects/<PROJECT>/LAYER_STATE.json

## AIM: HANDOFF
> source: ~/.ai-memory/projects/<PROJECT>/HANDOFF.md

...

## AIM: TODO
> source: ~/.ai-memory/projects/<PROJECT>/TODO.md

...

## Protocol
Update them at session end.
```

### ~/.claude/CLAUDE.md

```markdown
@~/.ai-memory/global/USER.md
## AIM Protocol
- CLAUDE.local.md 存在时记忆已自动注入
- Session 结束时更新 HANDOFF.md 和 TODO.md
```

---

## 记忆卫生

| 频率 | 动作 |
|------|------|
| 每次 Session | 更新 HANDOFF + TODO |
| 每周 | aim-archive.sh; TODO 清已完成 |
| 每月 | MEMORY Active 精炼 (<200行); PATTERNS 提炼 |

| 信号 | 动作 |
|------|------|
| HANDOFF > 40 行 | 精简 |
| MEMORY Active > 200 行 | 移旧到 Archived |
| SESSION-LOG > 10 条 | aim-archive.sh |
| 同一坑踩两次 | 写 PATTERNS.md |
