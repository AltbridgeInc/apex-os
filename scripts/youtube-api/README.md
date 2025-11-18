# YouTube API Scripts - Production Ready

Production-ready bash scripts for fetching YouTube data via YouTube Data API v3.

## Features

- **Video Search** - Search YouTube with keyword queries
- **Transcript Downloads** - Download video transcripts with proxy support
- **Channel Monitoring** - List videos from channels
- **Playlist Access** - Get videos from playlists
- **Clean Architecture** - Modular design following FMP scripts pattern
- **File-Based Output** - Transcripts saved with human-readable names
- **JSON Responses** - Structured responses for agent consumption
- **Proxy Support** - Webshare proxy for Docker/cloud environments

## Quick Start

### 1. Setup

Create `.env` file in apex-os/ with your YouTube API key:

```bash
echo "YOUTUBE_API_KEY=your_api_key_here" >> apex-os/.env
```

### 2. Install Dependencies

```bash
# System tools (usually pre-installed)
apt install curl jq python3  # Ubuntu/Debian
brew install curl jq python3  # macOS

# Python library for transcripts
pip3 install youtube-transcript-api
```

### 3. Usage

All operations use the master script `youtube-fetch.sh`:

```bash
./youtube-fetch.sh <command> [args...]
```

## Commands

### Search Videos

```bash
./youtube-fetch.sh search "NVIDIA earnings call" 10
./youtube-fetch.sh search "Warren Buffett interview" 25
```

### Download Transcript

```bash
./youtube-fetch.sh transcript abc123xyz
./youtube-fetch.sh transcript abc123xyz es
./youtube-fetch.sh transcript abc123xyz en transcripts/earnings/
```

**Output filename**: `youtube-{title}-{video_id}-{lang}.txt`

**Example**: `youtube-NVIDIA_Q3_2024_Earnings_Call-abc123xyz-en.txt`

### Get Channel Videos

```bash
./youtube-fetch.sh channel UC_x5XG1OV2P6uZZ5FSM9Ttw 20
```

### Get Playlist Videos

```bash
./youtube-fetch.sh playlist PLrAXtmErZgOeiKm4sgNOknGvNjby9efdf 50
```

## File Naming Convention

### Transcripts

**Pattern**: `youtube-{sanitized_title}-{video_id}-{lang}.txt`

**Examples**:
- `youtube-NVIDIA_Q3_2024_Earnings_Call-abc123xyz-en.txt`
- `youtube-Warren_Buffett_on_AI_Investing-def456uvw-en.txt`
- `youtube-Semiconductor_Trends_2025-ghi789rst-en.txt`

**Why this pattern**:
- **Title first** - Human-readable, browse files and understand content
- **Video ID included** - Ensures uniqueness, prevents conflicts
- **Language clear** - Know which language transcript
- **No symbol dependency** - Works for any video (not just stock-related)

### Title Sanitization Rules

- Remove invalid filename characters: `<>:"/\|?*`
- Remove punctuation: `',\.!;()[]{}`
- Replace spaces with underscores
- Remove non-alphanumeric (except `_` and `-`)
- Collapse multiple underscores
- Trim and limit to 100 characters

## Data Storage

```
apex-os/data/youtube/
├── transcripts/              # All transcripts here
│   ├── youtube-NVIDIA_Q3_2024_Earnings_Call-abc123xyz-en.txt
│   ├── youtube-Warren_Buffett_Interview-def456uvw-en.txt
│   └── youtube-Market_Outlook_2025-ghi789rst-en.txt
├── search/                   # Search result caches (optional)
└── metadata/                 # Channel/playlist metadata (optional)

apex-os/logs/
└── youtube-api.log          # Request logging
```

## Environment Variables

### Required

```bash
YOUTUBE_API_KEY=your_key              # Get from Google Cloud Console
```

### Optional

```bash
WEBSHARE_USERNAME=your_username       # For proxy support
WEBSHARE_PASSWORD=your_password       # For proxy support
YOUTUBE_DATA_DIR=apex-os/data/youtube # Auto-configured
YOUTUBE_LOG_DIR=apex-os/logs          # Auto-configured
```

## Proxy Support (for Transcripts)

YouTube's transcript API may block cloud IPs (Docker, GCP, AWS). Use Webshare proxy:

1. Sign up at [https://www.webshare.io/](https://www.webshare.io/)
2. Get credentials (free tier: 10 proxies, 1GB/month)
3. Add to apex-os/.env:
   ```bash
   WEBSHARE_USERNAME=your_username
   WEBSHARE_PASSWORD=your_password
   ```

Scripts auto-detect proxy credentials and use them when needed.

## JSON Response Format

All scripts return structured JSON:

### Success Response

```json
{
  "success": true,
  "operation": "transcript",
  "video_id": "abc123xyz",
  "video_title": "NVIDIA Q3 2024 Earnings Call",
  "sanitized_title": "NVIDIA_Q3_2024_Earnings_Call",
  "language": "en",
  "segments": 342,
  "size_kb": 45.2,
  "file": "/path/to/youtube-NVIDIA_Q3_2024_Earnings_Call-abc123xyz-en.txt",
  "using_proxy": false,
  "timestamp": "2024-11-18T12:34:56Z"
}
```

### Error Response

```json
{
  "success": false,
  "operation": "transcript",
  "error": {
    "type": "not_found",
    "message": "Video not found: abc123xyz"
  },
  "timestamp": "2024-11-18T12:34:56Z"
}
```

## Agent Integration

### Pattern 1: Search + Transcript Download

```bash
# Search for earnings calls
result=$(./youtube-fetch.sh search "NVIDIA Q3 2024 earnings" 5)

# Extract video IDs
video_ids=$(echo "$result" | jq -r '.videos[].video_id')

# Download transcripts
for vid in $video_ids; do
    ./youtube-fetch.sh transcript "$vid" en
done

# Analyze transcripts
for file in apex-os/data/youtube/transcripts/youtube-NVIDIA*.txt; do
    # Run analysis...
done
```

### Pattern 2: Channel Monitoring

```bash
# Get latest videos from IR channel
result=$(./youtube-fetch.sh channel UC_InvestorChannel 20)

# Download new transcripts
# Analyze for material information
```

## API Quota

YouTube Data API v3 quota limits (free tier):
- **Daily limit**: 10,000 units
- **Search**: 100 units per request
- **Videos**: 1 unit per request
- **Channels**: 1 unit per request
- **PlaylistItems**: 1 unit per request

**Tips**:
- Cache search results
- Use paid tier if needed ($0.002 per 1,000 units)
- Track quota usage in logs

## Error Handling

Common errors and solutions:

### API Key Issues

```
ERROR: YOUTUBE_API_KEY not set
```
→ Add key to apex-os/.env file

### Quota Exceeded

```
ERROR: YouTube API quota exceeded
```
→ Wait 24 hours or upgrade to paid tier

### Transcripts Disabled

```
ERROR: Transcripts are disabled for this video
```
→ Not all videos have transcripts

### Language Not Available

```
Warning: Language 'es' not available, using 'en'
```
→ Script auto-falls back to English

### Proxy Issues (Cloud/Docker)

```
ERROR: Could not fetch transcript
```
→ Add Webshare credentials to .env

## Dependencies

- **bash** (v4.0+)
- **curl** - HTTP requests
- **jq** - JSON parsing
- **python3** (v3.7+) - For transcript downloads
- **youtube-transcript-api** - Python package

## Architecture

```
youtube-api/
├── config.sh                 # Environment & paths
├── utils.sh                  # Validation & helpers
├── youtube-fetch.sh          # Master orchestrator
├── fetch-search.sh           # Video search
├── fetch-transcript.sh       # Transcript downloads
├── fetch-channel.sh          # Channel videos
├── fetch-playlist.sh         # Playlist videos
├── examples.sh               # Usage examples
├── README.md                 # This file
└── DATA_NAMING.md            # File naming specification
```

## Getting YouTube API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Enable "YouTube Data API v3"
4. Create credentials → API key
5. Copy key to apex-os/.env file

## Examples

See `examples.sh` for complete usage examples and agent workflows.

## Support

For issues:
1. Check logs in `apex-os/logs/youtube-api.log`
2. Validate `.env` has correct API key
3. Check API quota status
4. Review error messages in JSON responses

## License

Part of APEX-OS - MIT License
