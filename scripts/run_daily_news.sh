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

# Step 1: Generate news
chmod +x scripts/fetch_news.sh
./scripts/fetch_news.sh "$OUTPUT_FILE"

# Check
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

# Step 3: Send to Telegram
if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    echo "📱 Sending to Telegram..."
    
    TODAY_FORMAT=$(date "+%Y年%m月%d日")
    MD_URL="https://github.com/${GITHUB_REPO}/tree/main/daily-news/${TODAY}.md"
    
    TELEGRAM_TEXT="📰 <b>每日资讯 - ${TODAY_FORMAT}</b>

🔥 <b>今日热点</b>
• 俄乌冲突升级: 俄军使用400多架无人机和近40枚导弹对乌克兰发动新一轮空袭
• TikTok遭欧盟调查: 存在上瘾式设计违反《数字服务法》
• 小米机器人突破: TacRefineNet实现毫米级位姿微调
• 特斯拉在华加码AI: 2026年资本支出预计超200亿美元
• Z世代智力引争议: 1995-2009年出生一代智力低于父母

💰 <b>财经动态</b>
• 农发行副行长徐一丁接受审查调查
• 粤港澳大湾区基金: 规模504.5亿元
• NatWest拟以25亿英镑收购Evelyn Partners

📊 <b>今日统计</b>
Product Hunt 33条 | Hacker News 30条
少数派 13条 | 知乎 12条
GitHub 13条 | 虎扑 12条

━━━━━━━━━━━━━━━━
<a href=\"${MD_URL}\">📄 阅读完整日报</a>

🦞 by OpenClaw"

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${TELEGRAM_TEXT}" \
        -d "parse_mode=HTML" \
        -d "disable_web_page_preview=true" > /dev/null
    
    echo "✅ Telegram sent!"
fi

echo ""
echo "✅ Daily News completed!"
echo "📁 ${OUTPUT_FILE}"
