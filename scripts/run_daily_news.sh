#!/bin/bash
# Daily News Workflow - Main script

# Configuration
GITHUB_REPO="${GITHUB_REPO:-your-username/your-repo}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
OUTPUT_DIR="daily-news"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"

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
    
    # Initialize git if needed
    if [ ! -d ".git" ]; then
        git init
        git remote add origin "https://github.com/${GITHUB_REPO}.git"
    fi
    
    # Configure git
    git config user.email "bot@openclaw.ai"
    git config user.name "OpenClaw Bot"
    
    # Add and commit
    git add "$OUTPUT_FILE"
    git commit -m "Add daily news for ${TODAY}" 2>/dev/null
    
    # Push to GitHub (using token for auth)
    git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" main 2>/dev/null || \
    git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" master 2>/dev/null || \
    echo "⚠️ GitHub push failed (might need branch check)"
fi

# Step 3: Send to Telegram (if configured)
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    echo "📱 Sending summary to Telegram..."
    
    # Read the generated file content for the message
    NEWS_CONTENT=$(head -50 "$OUTPUT_FILE")
    
    # Create a concise Telegram message
    TELEGRAM_TEXT="🦞 *每日资讯 - ${TODAY}*

📰 *Product Hunt:* $(grep -c "\[" "$OUTPUT_FILE" | head -1) 条更新
💻 *Hacker News:* Top 10 热门故事
🐙 *GitHub Trending:* 今日趋势项目
📱 *少数派:* 最新文章
💬 *知乎:* 热榜话题

📄 完整日报已保存至 GitHub 仓库"

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${TELEGRAM_TEXT}" \
        -d "parse_mode=Markdown" > /dev/null
    
    echo "✅ Telegram message sent!"
fi

echo ""
echo "✅ Daily News workflow completed!"
echo "📁 Output: ${OUTPUT_FILE}"
