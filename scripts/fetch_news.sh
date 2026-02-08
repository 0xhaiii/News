#!/bin/bash
# Daily News Scraper - Fetches hot topics from multiple platforms

DATE=$(date +%Y-%m-%d)
OUTPUT_FILE="$1"
TELEGRAM_MSG_FILE="$2"

# Initialize the news report
cat > "$OUTPUT_FILE" << 'EOF'
---
title: 每日资讯
date: DATE_PLACEHOLDER
---

# 每日资讯 DATE_PLACEHOLDER

> 自动生成 by OpenClaw 🦞

## Product Hunt

EOF

# Product Hunt (RSS feed)
echo "Fetching Product Hunt..."
PH_CONTENT=$(curl -s "https://www.producthunt.com/feed" 2>/dev/null | head -20)
if [ -n "$PH_CONTENT" ]; then
    echo "$PH_CONTENT" >> "$OUTPUT_FILE"
else
    echo "- 暂无可用数据" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "## Hacker News" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Hacker News Top Stories (Firebase API)
echo "Fetching Hacker News..."
HN_DATA=$(curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" 2>/dev/null | head -30 | sed 's/\[//; s/\]//; s/,/\n/g')
if [ -n "$HN_DATA" ]; then
    for id in $(echo "$HN_DATA" | head -10); do
        ITEM=$(curl -s "https://hacker-news.firebaseio.com/v0/item/${id}.json" 2>/dev/null)
        TITLE=$(echo "$ITEM" | grep -o '"title":"[^"]*"' | head -1 | sed 's/"title":"//; s/"$//')
        URL=$(echo "$ITEM" | grep -o '"url":"[^"]*"' | head -1 | sed 's/"url":"//; s/"$//')
        if [ -n "$TITLE" ]; then
            echo "- [$TITLE]($URL)" >> "$OUTPUT_FILE"
        fi
    done
else
    echo "- 暂无可用数据" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "## GitHub Trending" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# GitHub Trending (unofficial API)
echo "Fetching GitHub Trending..."
GH_DATA=$(curl -s "https://github.com/trending/daily?spoken_language=en" 2>/dev/null | grep -oP 'href="/[^"]*"' | head -10 | sed 's/href="//; s/"$//')
if [ -n "$GH_DATA" ]; then
    for repo in $GH_DATA; do
        echo "- [github.com$repo](https://github.com$repo)" >> "$OUTPUT_FILE"
    done
else
    echo "- 暂无可用数据" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "## 少数派" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Sspai (RSS feed)
echo "Fetching Sspai..."
SSPAI_DATA=$(curl -s "https://sspai.com/feed" 2>/dev/null | head -30)
if [ -n "$SSPAI_DATA" ]; then
    echo "$SSPAI_DATA" >> "$OUTPUT_FILE"
else
    echo "- 暂无可用数据" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "## 知乎热榜" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Zhihu Hot (unofficial API - simplified)
echo "Fetching Zhihu Hot..."
ZHihu_DATA=$(curl -s "https://www.zhihu.com/api/v4/questions/19551136" 2>/dev/null | grep -oP '"title":"[^"]*"' | head -10 | sed 's/"title":"//; s/"$//')
if [ -n "$ZHihu_DATA" ]; then
    for title in $ZHihu_DATA; do
        echo "- $title" >> "$OUTPUT_FILE"
    done
else
    echo "- 暂无可用数据" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "*Generated at $(date '+%Y-%m-%d %H:%M:%S') by OpenClaw 🦞*" >> "$OUTPUT_FILE"

# Create Telegram message (shorter version)
cat > "$TELEGRAM_MSG_FILE" << 'EOF'
🦞 **每日资讯已更新！**

**Product Hunt:**
- Top products from today

**Hacker News:**
- Top 10 stories

**GitHub Trending:**
- Trending repositories today

**查看完整日报:** [GitHub Repo Link]

---
EOF

echo "✅ Daily news scraping completed!"
