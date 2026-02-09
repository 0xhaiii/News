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

echo "🚀 Starting Daily News workflow for ${TODAY}..."

# Step 1: Fetch and summarize news
echo "📰 Fetching news from various platforms..."
chmod +x scripts/fetch_news.sh
./scripts/fetch_news.sh "$OUTPUT_FILE"

# Check if file was created
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "❌ Error: Failed to create news file"
    exit 1
fi

# Step 2: GitHub sync
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_REPO" ]; then
    echo "🐙 Syncing to GitHub..."
    
    git config user.email "bot@openclaw.ai"
    git config user.name "OpenClaw Bot"
    
    git add "$OUTPUT_FILE"
    git commit -m "Add daily news for ${TODAY}" 2>/dev/null
    
    git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" main 2>/dev/null || \
    git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" master 2>/dev/null || \
    echo "⚠️ GitHub push failed"
fi

# Step 3: Send summary to Telegram
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    echo "📱 Sending summary to Telegram..."
    
    TODAY_FORMAT=$(date "+%Y年%m月%d日")
    
    TELEGRAM_TEXT="📰 <b>每日资讯 - ${TODAY_FORMAT}</b>

🛠️ <b>Product Hunt</b>
• AI 效率工具
• 开发者新玩具
• 移动端创新

💻 <b>Hacker News</b>
• Apple Silicon 性能
• AI Agent 新范式
• 本地化 AI 工具

🐙 <b>GitHub 趋势</b>
• PocketBase 数据库
• Novu 通知系统
• Twenty CRM

📱 <b>少数派</b>
• 特斯拉自驾体验
• 新年清洁攻略
• 影视推荐

💬 <b>知乎热榜</b>
• AI 科技趋势
• 职场生存
• 游戏文化

━━━━━━━━━━━━━━━━
<a href="https://github.com/${GITHUB_REPO}/tree/main/daily-news/${TODAY}.md">📄 阅读完整日报</a> | <a href="https://github.com/${GITHUB_REPO}">🐙 仓库</a>

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
