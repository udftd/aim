#!/bin/bash
# AIM — aim-add-module.sh <project> <module>
AIM="${AI_MEMORY_ROOT:-$HOME/.ai-memory}"
P="$1"; M="$2"
[ -z "$M" ] && echo "用法: aim-add-module.sh <project> <module>" && exit 1
PD="$AIM/projects/$P"
[ ! -d "$PD" ] && echo "❌ $P 不存在" && exit 1

MD="$PD/modules/$M"; mkdir -p "$MD"

cat > "$MD/CONTEXT.md" << EOF
---
project: $P
module: $M
tags: []
---
# Module: $M

## 是什么
[TODO]

## 关键区域
- [能力描述，非路径]

## 我的理解
- [清楚什么 / 不清楚什么]

## 踩坑
(待积累)

## 关联
- 依赖: [TODO]
- 被依赖: [TODO]
EOF

cat > "$MD/NOTES.md" << 'EOF'
# Working Notes

(随时追加)
EOF

[ ! -f "$PD/modules/_INDEX.md" ] && cat > "$PD/modules/_INDEX.md" << EOF
# Module Index — $P
## 活跃模块
| 模块 | 路径提示 | 熟悉度 | 最近 |
|------|---------|--------|------|

## 模块间关系
(待填写)
EOF

echo "✅ $M → $MD/"
