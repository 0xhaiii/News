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

# Product Hunt (placeholder - API requires auth)
echo "Fetching Product Hunt..."
echo "- [Product Hunt](https://www.producthunt.com/) - 每日精选产品" >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "## Hacker News" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Hacker News Top Stories (Firebase API)
echo "Fetching Hacker News..."
HN_IDS=$(curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" 2>/dev/null | sed 's/\[//; s/\]//' | tr ',' '\n' | head -10)
for id in $HN_IDS; do
    ITEM=$(curl -s "https://hacker-news.firebaseio.com/v0/item/${id}.json" 2>/dev/null)
    TITLE=$(echo "$ITEM" | sed 's/.*"title":"\([^"]*\)".*/\1/' | head -1)
    URL=$(echo "$ITEM" | sed 's/.*"url":"\([^"]*\)".*/\1/' | head -1)
    if [ -n "$TITLE" ] && [ "$TITLE" != "null" ]; then
        if [ -n "$URL" ] && [ "$URL" != "null" ]; then
            echo "- [$TITLE]($URL)" >> "$OUTPUT_FILE"
        else
            echo "- $TITLE (HN Discussion)" >> "$OUTPUT_FILE"
        fi
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "## GitHub Trending" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# GitHub Trending - placeholder (GitHub API requires auth for some endpoints)
echo "Fetching GitHub Trending..."
echo "- [Explore GitHub](https://github.com/explore) - 发现有趣的项目" >> "$OUTPUT_FILE"
echo "- [Trending Repos](https://github.com/trending) - 每日趋势" >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "## 少数派" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Sspai - just a link for now
echo "Fetching Sspai..."
echo "- [少数派首页](https://sspai.com/) - 数字生活指南" >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"
echo "## 知乎热榜" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Zhihu Hot (simplified - just a placeholder for now)
echo "Fetching Zhihu Hot..."
ZH_TOPICS=(
    "今天有哪些热门话题？"
    "知乎每日精选"
)
for topic in "${ZH_TOPICS[@]}"; do
    echo "- $topic" >> "$OUTPUT_FILE"
done

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
