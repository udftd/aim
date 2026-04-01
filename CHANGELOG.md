# AIM Changelog

## Unreleased
### Added
- Codex CLI: `AGENTS.override.md` 现在按 `LAYER_STATE.json` 展开当前激活层
- Projects: 新增 `LAYER_STATE.json` 作为 Claude / Codex 共享分层状态
### Changed
- aim_loader.py: 统一共享状态解析、纯文本渲染、Codex bridge 渲染
- aim-start.sh: 默认跟随共享分层状态，显式参数可覆盖
- AIM skills: 项目解析优先识别 `AGENTS.override.md`，兼容 Codex / Claude 双桥接

## 0.2
### New
- aim-upgrade.sh: 自升级命令，支持 --check 和 --source
### Changed
- aim-init.sh: 脚本复制改为 glob 匹配，自动写入 .aim-meta
- aim-bridge.sh: 工作流指令新增 SESSION-LOG 追加
### Bridge
- CLAUDE.local.md: 工作流指令措辞更新（新增 SESSION-LOG）

## 0.1
初始版本。
