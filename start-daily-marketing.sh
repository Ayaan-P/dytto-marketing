#!/bin/bash

# Dytto Daily Marketing Automation
# Master script that orchestrates all marketing activities

set -e

# Configuration
MARKETING_DIR="/home/rot/Projects/dytto-marketing"
SITE_DIR="/home/rot/Projects/dytto-site"
DATE_STAMP=$(date +%Y-%m-%d)
DAY_OF_WEEK=$(date +%A)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Banner
show_banner() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}                   ${GREEN}DYTTO DAILY MARKETING${NC}                    ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}              ${YELLOW}Context-Aware Brand Building${NC}               ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📅 Date:${NC} $DATE_STAMP"
    echo -e "${BLUE}📆 Day:${NC} $DAY_OF_WEEK"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if directories exist
    if [ ! -d "$MARKETING_DIR" ]; then
        error "Marketing directory not found: $MARKETING_DIR"
        exit 1
    fi
    
    if [ ! -d "$SITE_DIR" ]; then
        error "Site directory not found: $SITE_DIR"
        exit 1
    fi
    
    # Check if blog scripts exist
    if [ ! -f "$SITE_DIR/scripts/blog-create.sh" ]; then
        warning "Blog creation script not found - blog automation will be skipped"
    fi
    
    # Check if Reddit script exists
    if [ ! -f "/home/rot/Projects/Claude-Agentic-Files/lib/post-to-reddit.sh" ]; then
        warning "Reddit posting script not found - Reddit automation will be skipped"
    fi
    
    success "Prerequisites checked"
}

# Generate daily content theme
get_daily_theme() {
    case $DAY_OF_WEEK in
        "Monday")    echo "behavioral" ;;
        "Tuesday")   echo "technical" ;;
        "Wednesday") echo "industry" ;;
        "Thursday")  echo "stories" ;;
        "Friday")    echo "future" ;;
        "Saturday")  echo "community" ;;
        "Sunday")    echo "community" ;;
        *)           echo "general" ;;
    esac
}

# Generate content ideas based on theme
generate_content_ideas() {
    local theme=$1
    
    case $theme in
        "behavioral")
            echo "The Psychology of AI Understanding: Why Context Beats Content"
            ;;
        "technical")
            echo "Building Context-Aware AI: Beyond Prompt Engineering"
            ;;
        "industry")
            echo "The Context Wars: Who Will Win the Battle for User Understanding?"
            ;;
        "stories")
            echo "How AI Discovered the Story I Didn't Know I Was Living"
            ;;
        "future")
            echo "The Intelligence Revolution Begins With Understanding"
            ;;
        "community")
            echo "What's the Most Interesting Context About Your Day?"
            ;;
        *)
            echo "Building AI That Truly Understands Humans"
            ;;
    esac
}

# Create blog post
create_blog_post() {
    local theme=$1
    local title=$2
    
    log "Creating blog post for $theme theme..."
    
    if [ -f "$SITE_DIR/scripts/blog-create.sh" ]; then
        cd "$SITE_DIR"
        
        # Create the blog post
        ./scripts/blog-create.sh \
            --title "$title" \
            --category "$theme" \
            --author "Dytto Team" \
            --date "$DATE_STAMP"
        
        success "Blog post created: $title"
        
        # Return to marketing directory
        cd "$MARKETING_DIR"
    else
        warning "Blog creation skipped - script not found"
    fi
}

# Create social media content
create_social_content() {
    local theme=$1
    local title=$2
    
    log "Creating social media content..."
    
    # Create content directory if it doesn't exist
    mkdir -p "$MARKETING_DIR/content/$theme"
    
    # Twitter thread
    cat > "$MARKETING_DIR/content/$theme/twitter-thread-$DATE_STAMP.md" << EOF
# Twitter Thread: $title

## Thread Structure (8-12 tweets)

1/ 🧵 THREAD: $title

Why this matters for the future of AI... 👇

2/ Most AI today is like a brilliant person with amnesia.

It can answer complex questions but doesn't remember you had a bad day yesterday.

3/ Context isn't just data. It's the difference between:
• AI that processes information 
• AI that understands humans

4/ Think about it: Your best friend doesn't just know facts about you.

They understand your patterns, moods, and what makes you tick.

5/ This is what we're building at Dytto.

Not just another AI chatbot, but context infrastructure that makes AI truly understanding.

6/ The implications are huge:
• Healthcare AI that knows your stress patterns
• Education AI that adapts to your learning style  
• Productivity AI that understands your work rhythm

7/ We're not just building better AI.

We're building AI that gets you.

8/ What context about yourself do you wish AI understood better?

Drop your thoughts below 👇

#AI #Context #Understanding #Technology #Future
EOF

    success "Twitter thread created"
    
    # LinkedIn post
    cat > "$MARKETING_DIR/content/$theme/linkedin-post-$DATE_STAMP.md" << EOF
# LinkedIn Post: $title

$title

Most AI applications today suffer from context blindness. They process information brilliantly but lack the situational awareness that makes human intelligence so powerful.

At Dytto, we're solving this fundamental limitation by building context infrastructure for AI applications.

Here's why this matters:

🧠 **Human Intelligence is Contextual**
We don't just process facts—we understand situations, remember patterns, and adapt our responses based on context.

🤖 **Current AI Lacks Context**
Even the most advanced AI models are essentially very smart amnesiacs. They excel at processing information but struggle with understanding.

🔄 **The Context Solution**
By providing rich contextual understanding, we enable AI that truly comprehends users rather than just responding to them.

**For Developers**: Our APIs provide the context layer your AI applications need to understand users deeply.

**For Users**: Experience AI that knows not just what you said, but what you meant.

The future of AI isn't just about making it smarter—it's about making it more understanding.

What aspects of context do you think are most important for AI applications in your industry?

#ArtificialIntelligence #Technology #Innovation #Developers #Context
EOF

    success "LinkedIn post created"
}

# Generate analytics report
generate_analytics_report() {
    log "Generating daily analytics report..."
    
    # Create analytics directory if it doesn't exist
    mkdir -p "$MARKETING_DIR/analytics/reports"
    
    # Simple analytics report template
    cat > "$MARKETING_DIR/analytics/reports/daily-report-$DATE_STAMP.md" << EOF
# Daily Marketing Report - $DATE_STAMP

## Content Created Today
- **Theme**: $(get_daily_theme)
- **Blog Post**: "$(generate_content_ideas $(get_daily_theme))"
- **Social Media**: Twitter thread + LinkedIn post
- **Status**: Generated and ready for review

## Key Metrics to Track
- [ ] Blog post views and engagement
- [ ] Social media shares and comments
- [ ] Waitlist signups from today's content
- [ ] Developer API signups
- [ ] Reddit post performance

## Action Items
- [ ] Review and edit generated content
- [ ] Schedule social media posts
- [ ] Engage with community responses
- [ ] Track performance metrics

## Notes
Generated automatically by Dytto marketing automation system.
EOF

    success "Analytics report generated"
}

# Main execution
main() {
    show_banner
    
    # Get today's theme and content ideas
    THEME=$(get_daily_theme)
    TITLE=$(generate_content_ideas "$THEME")
    
    log "Today's marketing plan:"
    echo -e "${YELLOW}Theme:${NC} $THEME"
    echo -e "${YELLOW}Title:${NC} $TITLE"
    echo ""
    
    # Run marketing automation
    check_prerequisites
    create_blog_post "$THEME" "$TITLE"
    create_social_content "$THEME" "$TITLE"
    generate_analytics_report
    
    # Summary
    echo ""
    echo -e "${GREEN}🎉 Daily marketing automation complete!${NC}"
    echo ""
    echo -e "${BLUE}📋 What was created:${NC}"
    echo -e "   ✅ Blog post ready for review"
    echo -e "   ✅ Social media content templates"
    echo -e "   ✅ Daily analytics report"
    echo ""
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo -e "   1. Review and edit the generated content"
    echo -e "   2. Schedule social media posts"
    echo -e "   3. Publish blog post when ready"
    echo -e "   4. Engage with community responses"
    echo ""
    echo -e "${BLUE}📁 Content location:${NC} $MARKETING_DIR/content/$THEME/"
    echo -e "${BLUE}📊 Report location:${NC} $MARKETING_DIR/analytics/reports/"
    echo ""
}

# Make script executable and run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi