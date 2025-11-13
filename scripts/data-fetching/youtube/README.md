# YouTube Data Integration (Future Implementation)

## Status: STRUCTURE PREPARED - Implementation Deferred

YouTube integration structure has been prepared for future implementation but is **NOT required** for the current financial analysis workflow.

## Purpose

Fetch and process YouTube video transcripts from:
- Company earnings call videos
- Investor presentations
- Management interviews
- Conference presentations

## Implementation Pattern (When Ready)

### Two-Step Data Fetching Pattern

Following the FMP data integration pattern:

1. **Fetch Raw Data** (`get_video_transcript.sh`)
   - Bash script fetches raw transcript data from YouTube API
   - Saves raw JSON/XML data temporarily

2. **Process to Readable Format** (`process_transcript.py`)
   - Python script (stdlib only, no pip) processes raw data
   - Formats into readable markdown with timestamps
   - Saves to `data/youtube/` directory

### File Naming Convention

```
{symbol}-youtube-{video-id}-transcript.txt
```

Examples:
- `AAPL-youtube-dQw4w9WgXcQ-transcript.txt`
- `MSFT-youtube-abc123xyz-transcript.txt`

### Data Flow

```
YouTube API → get_video_transcript.sh → Raw JSON
             → process_transcript.py → Formatted transcript
             → data/youtube/{symbol}-youtube-{video-id}-transcript.txt
             → Agent receives FILE PATH (not raw data)
```

## Requirements (Future)

- YouTube API key
- `youtube-dl` or `yt-dlp` tool
- Python 3.x (stdlib only)

## Integration with Agents

When implemented, agents will:
1. Request transcript for specific video
2. Receive FILE PATH to saved transcript
3. Read transcript file as needed
4. Never receive raw transcript data inline

## Current Status

- Directory structure: ✓ Created
- Placeholder scripts: ✓ Created
- Pattern documented: ✓ Complete
- Implementation: ⏸ Deferred to future phase
- Blocker for refactoring: ❌ NO

## Notes

- YouTube integration is NOT a blocker for structural refactoring completion
- NOT required for current financial/technical analysis workflow
- Can be implemented later without affecting core functionality
- FMP data integration provides all necessary financial data
