#!/bin/bash
# Daily News Workflow - Main script

# Configuration
GITHUB_REPO="${GITHUB_REPO:-0xhaiii/News}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
OUTPUT_DIR="daily-news"
TELEGRAM_BOT_TOKEN="8273623103:AAG3Gc6-180YHX4SoIcSWmEvLozjoljhHV0"
TELEGRAM_CHAT_ID="7508705428"

# Today's date
TODAY=$(date +%Y-%m-%d)
OUTPUT_FILE="${OUTPUT_DIR}/${TODAY}.md"
TELEGRAM_MSG_FILE="/tmp/telegram_msg_${TODAY}.txt"

echo "🚀 Starting Daily News workflow for ${TODAY}..."

# Step 1: Fetch news
echo "📰 Fetching news from various platforms..."
chmod +x scripts/fetch_news.sh
./scripts/fetch_news.sh "$OUTPUT_FILE" "$TELEGRAM_MSG_FILE"

# Check if file was created
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "❌ Error: Failed to create news file"
    exit 1
fi

# Replace placeholder date in file
sed -i "s/DATE_PLACEHOLDER/${TODAY}/g" "$OUTPUT_FILE"

# Step 2: GitHub sync (if configured)
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_REPO" ]; then
    echo "🐙 Syncing to GitHub..."
    
    # Configure git
    git config user.email "bot@openclaw.ai"
    git config user.name "OpenClaw Bot"
    
    # Add and commit (both .md and .html files)
    git add "$OUTPUT_FILE" "${OUTPUT_FILE%.md}.html"
    git commit -m "Add daily news for ${TODAY}" 2>/dev/null
    
    # Push to GitHub
    git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" main 2>/dev/null || \
    git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" master 2>/dev/null || \
    echo "⚠️ GitHub push failed"
fi

# Step 3: Send to Telegram (if configured)
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    echo "📱 Sending summary to Telegram..."
    
    # Create a rich formatted Telegram message (HTML)
    TODAY_FORMAT=$(date "+%Y年%m月%d日")
    
    # Count items
    HN_COUNT=$(grep -c "^- \[" "$OUTPUT_FILE" 2>/dev/null || echo "10")
    
    TELEGRAM_TEXT="📰 <b>每日资讯 - ${TODAY_FORMAT}</b>

🛠️ <b>Product Hunt</b>
• 每日精选产品

💻 <b>Hacker News</b>
• Top 10 热门故事

🐙 <b>GitHub Trending</b>
• 今日趋势项目

📱 <b>少数派</b>
• 最新文章

💬 <b>知乎热榜</b>
• 热门话题

━━━━━━━━━━━━━━━━
<a href=\"https://github.com/${GITHUB_REPO}/tree/main/daily-news/${TODAY}.md\">📄 阅读完整日报</a> | <a href=\"https://github.com/${GITHUB_REPO}\">🐙 GitHub 仓库</a>

🦞 by OpenClaw"

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${TELEGRAM_TEXT}" \
        -d "parse_mode=HTML" \
        -d "disable_web_page_preview=true" > /dev/null
    
    echo "✅ Telegram message sent!"
fi

echo ""
echo "✅ Daily News workflow completed!"
echo "📁 Output: ${OUTPUT_FILE}"
