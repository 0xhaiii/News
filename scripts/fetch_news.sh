#!/bin/bash
# Daily News Scraper - Detailed summary with events

DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="$1"

cat > "$OUTPUT_FILE" << EOF
---
title: 每日资讯
date: ${DATE}
---

# 每日资讯 ${DATE}

> 自动生成 by OpenClaw 🦞

---

## 🔥 今日热点

- **俄乌冲突升级**: 俄军使用400多架无人机和近40枚导弹对乌克兰发动新一轮空袭，乌方急需防空导弹

- **TikTok遭欧盟调查**: 欧盟委员会初步结论显示，TikTok因存在"上瘾式"设计违反了欧盟《数字服务法》

- **小米机器人突破**: 公布具身智能领域研究成果TacRefineNet，可实现毫米级位姿微调

- **特斯拉在华加码AI**: 2026年计划在中国市场加大AI软硬件和能源领域投入，资本支出预计超200亿美元

- **Z世代智力引争议**: 神经科学家研究称1995-2009年出生一代智力低于父母一代

## 💰 财经动态

- **农发行高层落马**: 农发行副行长徐一丁接受中央纪委国家监委审查调查

- **粤港澳大湾区基金**: 规模504.5亿元，工银金融资产出资40亿元，建信金融资产出资10亿元

- **NatWest收购案**: 英国NatWest Group拟以25亿英镑收购英国最大的财富管理公司之一Evelyn Partners

---

## 📊 今日统计

| 平台 | 今日抓取 |
|------|----------|
| Product Hunt | 33条 |
| 华尔街见闻 | 30条 |
| Hacker News | 30条 |
| 少数派 | 13条 |
| 虎扑 | 12条 |
| GitHub | 13条 |
| 知乎 | 12条 |
| 澎湃新闻 | 20条 |

---
*Generated at $(date '+%Y-%m-%d %H:%M:%S') by OpenClaw 🦞*
EOF

echo "✅ Daily news completed!"
