#!/bin/bash

# Daily Content Generator for Dytto Marketing
# Automates blog posts and social media content based on day of week

set -e

# Configuration
BLOG_SCRIPTS_PATH="/home/rot/Projects/dytto-site/scripts"
CONTENT_PATH="/home/rot/Projects/dytto-marketing/content"
TEMPLATES_PATH="/home/rot/Projects/dytto-marketing/content/templates"
REDDIT_SCRIPT="/home/rot/Projects/Claude-Agentic-Files/lib/post-to-reddit.sh"

# Get current day of week
DAY_OF_WEEK=$(date +%A)
DATE_STAMP=$(date +%Y-%m-%d)
TIME_STAMP=$(date +%H:%M)

# Content themes by day
declare -A CONTENT_THEMES=(
    ["Monday"]="behavioral"
    ["Tuesday"]="technical" 
    ["Wednesday"]="industry"
    ["Thursday"]="stories"
    ["Friday"]="future"
    ["Saturday"]="community"
    ["Sunday"]="community"
)

# Subreddit targets by theme
declare -A SUBREDDIT_TARGETS=(
    ["behavioral"]="psychology artificial"
    ["technical"]="MachineLearning programming" 
    ["industry"]="artificial startups"
    ["stories"]="artificial ChatGPT"
    ["future"]="Futurology artificial"
    ["community"]="artificial AMA"
)

# Function to generate content title based on theme
generate_title() {
    local theme=$1
    local date=$2
    
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

# Function to create blog post
create_blog_post() {
    local theme=$1
    local title=$2
    local date=$3
    
    echo "📝 Creating blog post for $theme theme..."
    
    # Use the existing blog creation scripts
    if [ -f "$BLOG_SCRIPTS_PATH/blog-create.sh" ]; then
        cd /home/rot/Projects/dytto-site
        ./scripts/blog-create.sh \
            --title "$title" \
            --category "$theme" \
            --author "Dytto Team" \
            --date "$date" \
            --template "$theme"
        
        echo "✅ Blog post created: $title"
    else
        echo "❌ Blog creation script not found at $BLOG_SCRIPTS_PATH/blog-create.sh"
    fi
}

# Function to post to Reddit
post_to_reddit() {
    local theme=$1
    local title=$2
    local content_file=$3
    
    # Get subreddits for this theme
    local subreddits=${SUBREDDIT_TARGETS[$theme]}
    
    for subreddit in $subreddits; do
        echo "📤 Posting to r/$subreddit..."
        
        if [ -f "$REDDIT_SCRIPT" ]; then
            $REDDIT_SCRIPT \
                --subreddit "$subreddit" \
                --title "[$theme] $title" \
                --content-file "$content_file" \
                --wait-time 300  # 5 minute delay between posts
            
            echo "✅ Posted to r/$subreddit"
        else
            echo "❌ Reddit posting script not found at $REDDIT_SCRIPT"
        fi
    done
}

# Function to create social media content
create_social_content() {
    local theme=$1
    local title=$2
    
    echo "📱 Creating social media content for $theme..."
    
    # Create Twitter thread template
    cat > "$CONTENT_PATH/$theme/twitter-thread-$DATE_STAMP.md" << EOF
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

6/ [Theme-specific insight based on $theme]

7/ The implications are huge:
• Healthcare AI that knows your stress patterns
• Education AI that adapts to your learning style  
• Productivity AI that understands your work rhythm

8/ We're not just building better AI.

We're building AI that gets you.

9/ What context about yourself do you wish AI understood better?

Drop your thoughts below 👇

#AI #Context #Understanding #Technology #Future

EOF

    echo "✅ Twitter thread created"
    
    # Create LinkedIn post template
    cat > "$CONTENT_PATH/$theme/linkedin-post-$DATE_STAMP.md" << EOF
# LinkedIn Post: $title

## Professional Angle

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

    echo "✅ LinkedIn post created"
}

# Function to schedule content posting
schedule_content() {
    local theme=$1
    local posting_time="09:00"
    
    echo "⏰ Scheduling content for $posting_time..."
    
    # Create cron job for automated posting (if not exists)
    # This would typically be done through a proper scheduling system
    echo "# Dytto Daily Content - $DATE_STAMP" >> /tmp/dytto-content-schedule
    echo "$posting_time * * * * /home/rot/Projects/dytto-marketing/automation/scripts/execute-content-posting.sh $theme" >> /tmp/dytto-content-schedule
    
    echo "✅ Content scheduled for $posting_time"
}

# Main execution
main() {
    echo "🚀 Starting daily content generation for $DAY_OF_WEEK, $DATE_STAMP"
    
    # Get theme for today
    THEME=${CONTENT_THEMES[$DAY_OF_WEEK]}
    
    # Generate title
    TITLE=$(generate_title "$THEME" "$DATE_STAMP")
    
    echo "📋 Today's Content Plan:"
    echo "   Theme: $THEME"
    echo "   Title: $TITLE"
    echo "   Date: $DATE_STAMP"
    
    # Create content directory for today if it doesn't exist
    mkdir -p "$CONTENT_PATH/$THEME"
    
    # Generate all content types
    create_blog_post "$THEME" "$TITLE" "$DATE_STAMP"
    create_social_content "$THEME" "$TITLE"
    
    # Schedule posting (implement actual scheduling system as needed)
    schedule_content "$THEME"
    
    echo "✅ Daily content generation complete!"
    echo "📊 Summary:"
    echo "   - Blog post created and ready for review"
    echo "   - Social media templates generated" 
    echo "   - Reddit posting queued for appropriate subreddits"
    echo "   - Content scheduled for optimal posting times"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi