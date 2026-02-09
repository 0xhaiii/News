#!/bin/bash
# Daily News - Using Python for reliable JSON parsing

DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="$1"

echo "Fetching news with Python..."

# Get HN IDs
HN_IDS=$(curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" 2>/dev/null | python3 -c "import sys,json; print(' '.join([str(x) for x in json.load(sys.stdin)[:8]]))")

cat > "$OUTPUT_FILE" << EOF
---
title: 每日资讯
date: ${DATE}
---

# 每日资讯 ${DATE}

> 自动生成 by OpenClaw 🦞

---

## 💻 Hacker News 今日热门

EOF

for id in $HN_IDS; do
    ITEM=$(curl -s "https://hacker-news.firebaseio.com/v0/item/${id}.json" 2>/dev/null)
    TITLE=$(echo "$ITEM" | python3 -c "import sys,json; print(json.load(sys.stdin).get('title',''))" 2>/dev/null)
    SCORE=$(echo "$ITEM" | python3 -c "import sys,json; print(json.load(sys.stdin).get('score',0))" 2>/dev/null)
    URL=$(echo "$ITEM" | python3 -c "import sys,json; u=json.load(sys.stdin).get('url',''); print(u.split('//')[-1].split('/')[0] if u else 'news.ycombinator.com')" 2>/dev/null)
    
    if [ -n "$TITLE" ]; then
        echo "- **$TITLE** ($URL · ⭐ $SCORE)" >> "$OUTPUT_FILE"
    fi
done

cat >> "$OUTPUT_FILE" << EOF

## 🔗 其他来源

- 🌍 BBC: https://www.bbc.com/news
- 📱 Product Hunt: https://producthunt.com
- 💬 知乎: https://www.zhihu.com/hot

---

## 📊 统计

| 来源 | 数量 |
|------|------|
| Hacker News | $(echo $HN_IDS | wc -w) 条 |

---
*Generated at $(date '+%Y-%m-%d %H:%M:%S') by OpenClaw 🦞*
EOF

echo "✅ Done!"
