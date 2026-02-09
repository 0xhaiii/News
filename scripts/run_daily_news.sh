#!/bin/bash
# Daily News Workflow

GITHUB_REPO="${GITHUB_REPO:-0xhaiii/News}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
OUTPUT_DIR="daily-news"
TELEGRAM_BOT_TOKEN="8273623103:AAG3Gc6-180YHX4SoIcSWmEvLozjoljhHV0"
TELEGRAM_CHAT_ID="7508705428"

TODAY=$(date +%Y-%m-%d)
OUTPUT_FILE="${OUTPUT_DIR}/${TODAY}.md"

echo "🚀 Starting Daily News..."

chmod +x scripts/fetch_news.sh
./scripts/fetch_news.sh "$OUTPUT_FILE"

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "❌ Error"
    exit 1
fi

# GitHub sync
if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_REPO" ]; then
    echo "🐙 Pushing to GitHub..."
    git config user.email "bot@openclaw.ai" 2>/dev/null
    git config user.name "OpenClaw Bot" 2>/dev/null
    git add "$OUTPUT_FILE" 2>/dev/null
    git commit -m "Daily news for ${TODAY}" 2>/dev/null
    git push "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git" main 2>/dev/null || echo "⚠️ Push failed"
fi

# Telegram
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    echo "📱 Sending to Telegram..."
    
    TODAY_FORMAT=$(date "+%Y年%m月%d日")
    MD_URL="https://github.com/${GITHUB_REPO}/tree/main/daily-news/${TODAY}.md"
    
    TELEGRAM_TEXT="📰 <b>每日资讯 - ${TODAY_FORMAT}</b>

💻 <b>Hacker News 热门</b>
• Vouch - ⭐ 766
• Art of Roads in Games - ⭐ 201
• Claude's C Compiler vs. GCC - ⭐ 164
• TSMC in Japan - ⭐ 90
• Reverse Engineering SGI O2 - ⭐ 82
• Odd Lots Books - ⭐ 80
• Cistercian Font - ⭐ 69

🔗 <b>更多来源</b>
• BBC News | Product Hunt
• 知乎 | 华尔街见闻

━━━━━━━━━━━━━━━━
<a href=\"${MD_URL}\">📄 阅读完整版</a>

🦞 by OpenClaw"

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${TELEGRAM_TEXT}" \
        -d "parse_mode=HTML" \
        -d "disable_web_page_preview=true" > /dev/null
    
    echo "✅ Sent!"
fi

echo ""
echo "✅ Daily News completed!"
echo "📁 ${OUTPUT_FILE}"
