#!/bin/bash

# Free News Intelligence System for Dytto Marketing
# Uses free APIs to monitor brand mentions, competitors, and trends

set -e

# Configuration
NEWS_API_KEY="YOUR_FREE_NEWSAPI_ORG_KEY"  # Get from newsapi.org
DATE_STAMP=$(date +%Y-%m-%d)
OUTPUT_DIR="/home/rot/Projects/dytto-marketing/analytics/reports"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Search terms for monitoring
DYTTO_TERMS="dytto OR \"context-aware AI\" OR \"contextual intelligence\""
COMPETITORS="openai OR anthropic OR \"claude ai\" OR chatgpt"
AI_TRENDS="\"artificial intelligence\" AND (context OR understanding OR memory)"

log "Starting free news intelligence monitoring..."

# 1. NEWS API MONITORING (Free Tier)
monitor_news_api() {
    local query=$1
    local category=$2
    
    log "Monitoring NewsAPI for: $category"
    
    if [ -n "$NEWS_API_KEY" ] && [ "$NEWS_API_KEY" != "YOUR_FREE_NEWSAPI_ORG_KEY" ]; then
        curl -s "https://newsapi.org/v2/everything?q=$query&apiKey=$NEWS_API_KEY&pageSize=20&sortBy=publishedAt" \
            | jq -r '.articles[] | "[\(.publishedAt)] \(.title) - \(.url)"' \
            > "$OUTPUT_DIR/${category}_news_$DATE_STAMP.txt"
        
        success "$category news monitoring complete"
    else
        echo "⚠️  NewsAPI key not set - skipping news monitoring"
    fi
}

# 2. REDDIT MONITORING (Completely Free)
monitor_reddit() {
    local query=$1
    local category=$2
    
    log "Monitoring Reddit for: $category"
    
    # Search multiple AI subreddits
    for subreddit in artificial MachineLearning ChatGPT OpenAI singularity; do
        curl -s "https://www.reddit.com/r/$subreddit/search.json?q=$query&limit=5&sort=new" \
            -H "User-Agent: DyttoBot/1.0" \
            | jq -r '.data.children[]? | .data | "[\(.created_utc | strftime("%Y-%m-%d %H:%M"))] \(.title) (\(.score) points) - https://reddit.com\(.permalink)"' \
            >> "$OUTPUT_DIR/${category}_reddit_$DATE_STAMP.txt" 2>/dev/null
    done
    
    success "$category Reddit monitoring complete"
}

# 3. HACKERNEWS MONITORING (Completely Free)
monitor_hackernews() {
    local query=$1
    local category=$2
    
    log "Monitoring HackerNews for: $category"
    
    # Get top stories and search for relevant terms
    curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" \
        | jq '.[:50]' \
        | jq -r '.[]' \
        | while read story_id; do
            story_data=$(curl -s "https://hacker-news.firebaseio.com/v0/item/$story_id.json")
            title=$(echo "$story_data" | jq -r '.title // empty')
            url=$(echo "$story_data" | jq -r '.url // empty')
            score=$(echo "$story_data" | jq -r '.score // 0')
            
            # Simple keyword matching (case insensitive)
            if echo "$title" | grep -qi "AI\|artificial\|context\|intelligence\|machine learning"; then
                echo "[$score points] $title - $url" >> "$OUTPUT_DIR/${category}_hackernews_$DATE_STAMP.txt"
            fi
        done
    
    success "$category HackerNews monitoring complete"
}

# 4. BASIC SENTIMENT ANALYSIS (Free with keyword matching)
analyze_sentiment() {
    local file=$1
    local category=$2
    
    log "Analyzing sentiment for: $category"
    
    if [ -f "$file" ]; then
        positive_words="good|great|excellent|amazing|breakthrough|revolutionary|innovative|successful|positive"
        negative_words="bad|terrible|awful|failure|problem|issue|concern|negative|disappointing"
        
        positive_count=$(grep -i -E "$positive_words" "$file" | wc -l)
        negative_count=$(grep -i -E "$negative_words" "$file" | wc -l)
        total_count=$(wc -l < "$file")
        
        echo "=== SENTIMENT ANALYSIS: $category ===" >> "$OUTPUT_DIR/sentiment_$DATE_STAMP.txt"
        echo "Total mentions: $total_count" >> "$OUTPUT_DIR/sentiment_$DATE_STAMP.txt"
        echo "Positive indicators: $positive_count" >> "$OUTPUT_DIR/sentiment_$DATE_STAMP.txt"
        echo "Negative indicators: $negative_count" >> "$OUTPUT_DIR/sentiment_$DATE_STAMP.txt"
        echo "Sentiment ratio: $((positive_count * 100 / (total_count + 1)))% positive" >> "$OUTPUT_DIR/sentiment_$DATE_STAMP.txt"
        echo "" >> "$OUTPUT_DIR/sentiment_$DATE_STAMP.txt"
    fi
}

# 5. GENERATE DAILY REPORT
generate_report() {
    log "Generating daily intelligence report..."
    
    cat > "$OUTPUT_DIR/daily_intelligence_$DATE_STAMP.md" << EOF
# Daily Marketing Intelligence Report - $DATE_STAMP

## Executive Summary
This report aggregates intelligence from free news sources, Reddit discussions, and HackerNews trends.

## Brand Mentions (Dytto & Context-Aware AI)
$([ -f "$OUTPUT_DIR/brand_news_$DATE_STAMP.txt" ] && echo "### News Coverage" && head -10 "$OUTPUT_DIR/brand_news_$DATE_STAMP.txt" || echo "No brand news found today")

$([ -f "$OUTPUT_DIR/brand_reddit_$DATE_STAMP.txt" ] && echo "### Reddit Discussions" && head -5 "$OUTPUT_DIR/brand_reddit_$DATE_STAMP.txt" || echo "No brand Reddit discussions found")

## Competitor Activity
$([ -f "$OUTPUT_DIR/competitors_news_$DATE_STAMP.txt" ] && echo "### Competitor News" && head -10 "$OUTPUT_DIR/competitors_news_$DATE_STAMP.txt" || echo "No competitor news found today")

$([ -f "$OUTPUT_DIR/competitors_reddit_$DATE_STAMP.txt" ] && echo "### Competitor Reddit Activity" && head -5 "$OUTPUT_DIR/competitors_reddit_$DATE_STAMP.txt" || echo "No competitor Reddit activity found")

## AI Industry Trends
$([ -f "$OUTPUT_DIR/trends_hackernews_$DATE_STAMP.txt" ] && echo "### HackerNews Trending" && head -10 "$OUTPUT_DIR/trends_hackernews_$DATE_STAMP.txt" || echo "No AI trends found on HackerNews today")

## Sentiment Analysis
$([ -f "$OUTPUT_DIR/sentiment_$DATE_STAMP.txt" ] && cat "$OUTPUT_DIR/sentiment_$DATE_STAMP.txt" || echo "Sentiment analysis not available")

## Content Opportunities
Based on today's intelligence, consider creating content about:
- $(grep -i "context\|AI\|intelligence" "$OUTPUT_DIR"/*_$DATE_STAMP.txt 2>/dev/null | head -3 | sed 's/.*: */- /' || echo "No specific opportunities identified today")

## Action Items
- [ ] Review brand mentions for response opportunities
- [ ] Monitor competitor announcements for strategic implications
- [ ] Create content based on trending topics
- [ ] Engage with relevant Reddit discussions

---
*Generated by Dytto Free Marketing Intelligence System*
EOF

    success "Daily report generated: $OUTPUT_DIR/daily_intelligence_$DATE_STAMP.md"
}

# MAIN EXECUTION
main() {
    echo ""
    echo "🆓 DYTTO FREE MARKETING INTELLIGENCE"
    echo "📅 Date: $DATE_STAMP"
    echo ""
    
    # Monitor different categories
    monitor_news_api "$DYTTO_TERMS" "brand"
    monitor_reddit "dytto context AI" "brand"
    
    monitor_news_api "$COMPETITORS" "competitors"
    monitor_reddit "openai anthropic claude" "competitors"
    
    monitor_hackernews "AI trends" "trends"
    
    # Analyze sentiment
    analyze_sentiment "$OUTPUT_DIR/brand_news_$DATE_STAMP.txt" "Brand News"
    analyze_sentiment "$OUTPUT_DIR/competitors_news_$DATE_STAMP.txt" "Competitor News"
    
    # Generate comprehensive report
    generate_report
    
    echo ""
    echo "✅ Free intelligence monitoring complete!"
    echo "📊 Reports saved to: $OUTPUT_DIR"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Review the daily report"
    echo "   2. Set up NewsAPI.org free account for news monitoring"
    echo "   3. Schedule this script to run daily"
    echo "   4. Use insights for content creation"
    echo ""
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi