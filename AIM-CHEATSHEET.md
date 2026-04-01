# AIM — 速查卡

## 命令

```bash
aim-init.sh                              # 全局初始化
aim-init.sh my-app                       # 开发模式
aim-init.sh my-app --study               # 研读/接手
aim-init.sh kubernetes --study --large   # 研读大型项目
aim-bridge.sh my-app . --tools all       # 桥接所有工具
aim-start.sh my-app                      # L0 ~800 tok
aim-start.sh kubernetes api-server       # L0+L1 ~1300 tok
aim-start.sh kubernetes --with memory    # L0+L2
aim-start.sh kubernetes --budget 2000    # 硬限 token
aim-end.sh my-app                        # 结束检查
aim-archive.sh my-app                    # 归档溢出 session
aim-search.sh "timeout" kubernetes       # 搜索
aim-add-module.sh kubernetes scheduler   # 添加模块
```

## 流程

```
首次:  aim-init.sh <p> → aim-bridge.sh <p> . → 开始
日常:  工具自动加载 → 工作 → "更新 handoff" → aim-end.sh <p>
切换:  AI-A 写 handoff → AI-B 读 → 续上
Web:   aim-start.sh <p> → 粘贴 → 工作 → 复制 handoff → 覆盖
```

## 研读项目第一个 Prompt

```
请阅读项目目录结构和 README，帮我梳理模块划分和架构。然后更新 handoff。
```

## HANDOFF: < 40行 | 状态快照不写过程

## 分层: 改 `LAYER_STATE.json` 后重新跑 `aim-bridge.sh`

## 经济性: ~$0.014/session | 日均 ~$0.075

## 卫生: HANDOFF<40行 | MEMORY<200行 | LOG≤10条 | Done≤5个
