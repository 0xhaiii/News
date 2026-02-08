---
name: daily-news
description: Daily news digest that fetches hot topics from Product Hunt, Hacker News, GitHub Trending, 少数派, and 知乎. Automatically generates a Markdown report, syncs to GitHub, and sends summaries to Telegram at 10:00 AM daily.
---

# Daily News Skill

Automated daily news digest for staying updated on tech and trending topics.

## Features

- **Multi-platform aggregation**: Product Hunt, Hacker News, GitHub Trending, 少数派, 知乎
- **Auto-generated reports**: Markdown format with date-based filenames
- **GitHub sync**: Commits daily reports to your repository
- **Telegram delivery**: Sends summary to your Telegram chat
- **Scheduled execution**: Runs automatically at 10:00 AM daily

## Usage

### Manual Trigger

```bash
cd /Users/0xhai/.openclaw/skills/daily-news
./scripts/run_daily_news.sh
```

### Setup Instructions

**1. Configure GitHub (optional):**
```bash
export GITHUB_REPO="your-username/your-repo-name"
export GITHUB_TOKEN="your-github-token"
```

**2. Configure Telegram (optional):**
```bash
export TELEGRAM_BOT_TOKEN="your-bot-token"
export TELEGRAM_CHAT_ID="your-chat-id"
```

**3. Setup Cron Job (10:00 AM daily):**
```bash
# Edit crontab
crontab -e

# Add this line:
0 10 * * * cd /Users/0xhai/.openclaw/skills/daily-news && ./scripts/run_daily_news.sh >> /tmp/daily_news.log 2>&1
```

## Output

- **Markdown files**: `daily-news/YYYY-MM-DD.md`
- **GitHub repository**: Daily commits with new files
- **Telegram**: Daily summary message at 10:00 AM

## Example Output

```markdown
# 每日资讯 2026-02-08

> 自动生成 by OpenClaw 🦞

## Product Hunt
- [Product Name](url) - Description

## Hacker News
- [Story Title](url) - Points

## GitHub Trending
- [repo-name](github-link) - Stars

## 少数派
- [Article Title](url)

## 知乎热榜
- 问题标题
```

## Files

```
daily-news/
├── SKILL.md
└── scripts/
    ├── fetch_news.sh      # Fetches news from platforms
    └── run_daily_news.sh  # Main workflow script
```

## Notes

- News APIs may have rate limits - script handles basic errors
- GitHub token needs repo write permissions
- Telegram bot must be added to the chat
- First run creates the daily-news directory
