# SESSION.md — AIM 项目会话记录

每条记录对应一次工作会话，最新在最上方。

---

## 2026-04-03

**做了什么**
- 审查 aim-search.sh 搜索范围，确认默认模式已递归搜索 modules/ 但缺少专用过滤器
- 为 aim-search.sh 添加 `--type modules` 支持，可只搜索 `modules/` 目录下的 .md 文件

**未完成 / 待跟进**
- 无

---

## 2026-04-02

**做了什么**
- 审核 CLAUDE.local.md 分层记忆设计（L0-L4），发现三个问题：
  - HTML 注释被 Claude Code 剥离后，空的层标题浪费 token
  - 停用层对 AI 完全不可见，无"按需升层"路径
  - 分层标签（L0/L1/L2/L3/L4）增加复杂度但不帮助 AI
- 简化 CLAUDE.local.md：去掉所有分层标签和 HTML 注释占位，只保留 `@HANDOFF.md` + `@TODO.md` + 激活模块的 `@CONTEXT.md` + 工作流指令
- 模块切换由 `/aim-module` skill 管理，其他记忆文件靠 AI 按需 Read
- 更新 README.md：简化分层加载段落，清理已完成 TODO
- 更新 ~/workspace/projects 下 4 个项目的 CLAUDE.local.md 到新模板（kubernetes、openclaw、kubernetes-autoscaler、ffmpeg）

**未完成 / 待跟进**
- [ ] aim-bridge.sh 中 `has_layer`/`ACTIVE_LAYERS`/`LAYER_STATE.json` 相关代码可进一步清理（Codex 段的 `aim_loader.py render` 仍依赖）
- [ ] aim-module skill 中 Step 3 仍引用旧的注释/取消注释机制，需同步更新

---

## 2026-03-29

**做了什么**
- 设计并实现 5 个 Claude Code skills，将 shell 脚本封装为智能工作流：
  - `/aim-onboard`：init + 自动填充 PROJECT.md + bridge + 模块发现
  - `/aim-session-end`：更新 HANDOFF/TODO/SESSION-LOG + 健康检查 + 自动归档
  - `/aim-module`：创建/切换模块 + 探索源码填充 CONTEXT.md + L1 层切换
  - `/aim-health`：健康检查 + 归档 + MEMORY 精简 + TODO 清理
  - `/aim-search`：搜索记忆 + 结果分组解读
- 创建 `.claude-plugin/plugin.json` 和 `marketplace.json` 插件脚手架
- 修复所有 skill 的 `$AIM_BIN` 路径解析（从 "plugin repo root" 改为 `~/.ai-memory/bin/` + `which` fallback）
- 安装 skills 到 `~/.claude/skills/`（全局生效）
- 尝试 marketplace 注册方式安装插件，发现需要手动 clone marketplace 仓库，暂未完成

**未完成 / 待跟进**
- [ ] marketplace 安装方式：需要 `git clone` aim 仓库到 `~/.claude/plugins/marketplaces/aim/` 才能通过 `claude plugins install aim@aim` 安装
- [ ] `aim-layer.sh`：多层记忆加载优化（上次遗留）
- [ ] skills 实际使用测试：在真实项目上验证各 skill 的触发和执行效果

---

## 2026-03-28

**做了什么**
- 阅读全部源码，深入理解多级记忆加载��制（L0–L4）
- 梳理了大型项目（以 kubernetes 为例）的完整 AIM 工作流
- 实现升级机制：
  - 新增 `VERSION`、`CHANGELOG.md`、`aim-upgrade.sh`
  - `aim-init.sh` 脚本列表改为 glob 匹配，安装后写入 `.aim-meta`
  - `aim-upgrade.sh` 支持 `--check`、`--force`、`--source`
  - `aim-upgrade.sh` 不打包到 `~/.ai-memory/bin/`，只在仓库目录运行
- 修复 `aim-bridge.sh` 两个问题：
  - 工作流指���中新增 SESSION-LOG 追加要求
  - CLAUDE.local.md 中工作流指令被注释导致 AI 读不到，改为明文输出
- 更新 README.md TODO：升级机制标记完成，多层加载优化待做

**未完成 / 待跟进**
- [ ] `aim-layer.sh`：多层记忆加载优化，自动切换 CLAUDE.local.md 中的层级和模块

---

## 2026-03-27

**做了什么**
- 将项目推送到 GitHub（切换 remote 为 SSH，添加 github.com 到 known_hosts）
- 阅读全部源码（7 个脚本 + 2 个文档）
- 生成 CLAUDE.md，记录项目架构、命令、分层加载策略和桥接文件格式

**项目理解摘要**
- AIM 是纯 bash 的 AI 记忆管理工具，核心思想：在 `~/.ai-memory/` 维护结构化 Markdown，供多种 AI 工具（Claude Code、Cursor、Cline 等）跨 session 加载上下文
- `aim-init.sh` 初始化全局结构和项目（dev/study/large 三种模式）
- `aim-bridge.sh` 在项目源码目录生成各 AI 工具的桥接文件（CLAUDE.local.md、.clinerules/ 等），文件会被加入 .gitignore
- `aim-start.sh` 分层拼接上下文到剪贴板，供 Web 版 AI 使用，支持 --budget token 预算
- `aim-end.sh` 做 session 结束健康检查：文件更新时间、行数上限、模块 CONTEXT.md 是否仍为空模板
- 分层加载：L0（HANDOFF+TODO ~800tok）→ L1（模块 CONTEXT）→ L2（MEMORY）→ L3（DECISIONS）→ L4（USER）
- `AI_MEMORY_ROOT` 环境变量可覆盖默认存储路径 `~/.ai-memory/`

**未完成 / 待跟进**
- 无
