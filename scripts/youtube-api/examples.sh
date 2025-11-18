#!/usr/bin/env bash
# YouTube API - Usage Examples
# Demonstrates common use cases and workflows

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YOUTUBE_FETCH="$SCRIPT_DIR/youtube-fetch.sh"

echo "======================================================================"
echo "YouTube API - Usage Examples"
echo "======================================================================"
echo ""

# Example 1: Search for videos
echo "Example 1: Search for NVIDIA earnings calls"
echo "--------------------------------------------------------------------"
echo "Command: youtube-fetch.sh search \"NVIDIA Q3 2024 earnings call\" 5"
echo ""
bash "$YOUTUBE_FETCH" search "NVIDIA Q3 2024 earnings call" 5
echo ""

# Example 2: Download transcript (requires video ID from search)
echo "Example 2: Download transcript"
echo "--------------------------------------------------------------------"
echo "Note: Replace 'VIDEO_ID' with actual video ID from search results"
echo "Command: youtube-fetch.sh transcript VIDEO_ID en"
echo ""
echo "# bash youtube-fetch.sh transcript abc123xyz en"
echo "# Output: youtube-NVIDIA_Q3_2024_Earnings_Call-abc123xyz-en.txt"
echo ""

# Example 3: Get channel videos
echo "Example 3: Get videos from investor relations channel"
echo "--------------------------------------------------------------------"
echo "Note: Replace CHANNEL_ID with actual channel ID"
echo "Command: youtube-fetch.sh channel UC_CHANNEL_ID 10"
echo ""
echo "# bash youtube-fetch.sh channel UC_x5XG1OV2P6uZZ5FSM9Ttw 10"
echo ""

# Example 4: Get playlist videos
echo "Example 4: Get videos from industry playlist"
echo "--------------------------------------------------------------------"
echo "Note: Replace PLAYLIST_ID with actual playlist ID"
echo "Command: youtube-fetch.sh playlist PL_PLAYLIST_ID 20"
echo ""
echo "# bash youtube-fetch.sh playlist PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf 20"
echo ""

# Agent workflow example
echo "Example 5: Agent Workflow - Analyze Earnings Calls"
echo "--------------------------------------------------------------------"
cat << 'EOF'
# 1. Search for earnings calls
result=$(bash youtube-fetch.sh search "TSLA Q3 2024 earnings" 5)

# 2. Extract video IDs
video_ids=$(echo "$result" | jq -r '.videos[].video_id')

# 3. Download transcripts
for vid in $video_ids; do
    bash youtube-fetch.sh transcript "$vid" en
done

# 4. Analyze transcripts
for file in apex-os/data/youtube/transcripts/youtube-TSLA*.txt; do
    echo "Analyzing: $file"
    # Run analysis here...
done
EOF
echo ""

# Example 6: Custom output directory
echo "Example 6: Save transcript to custom directory"
echo "--------------------------------------------------------------------"
echo "Command: youtube-fetch.sh transcript VIDEO_ID en research/earnings/"
echo ""
echo "# bash youtube-fetch.sh transcript abc123xyz en research/earnings/"
echo "# Output: research/earnings/youtube-Title-abc123xyz-en.txt"
echo ""

# Example 7: Different language
echo "Example 7: Download Spanish transcript"
echo "--------------------------------------------------------------------"
echo "Command: youtube-fetch.sh transcript VIDEO_ID es"
echo ""
echo "# bash youtube-fetch.sh transcript abc123xyz es"
echo "# Output: youtube-Title-abc123xyz-es.txt"
echo ""

echo "======================================================================"
echo "For full documentation, see README.md"
echo "======================================================================"
