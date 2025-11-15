#!/usr/bin/env python3
"""
Process FMP transcript JSON files into readable text format.
Reads from cached JSON, outputs formatted text file.

Usage:
    python3 process-transcript.py <json_file> [output_file]
"""
import json
import sys
from pathlib import Path
from datetime import datetime

def process_transcript(json_path: str, output_path: str = None):
    """Convert transcript JSON to readable text format."""
    json_file = Path(json_path)

    with open(json_file, 'r') as f:
        data = json.load(f)

    # Handle single transcript or array
    transcripts = data if isinstance(data, list) else [data]

    processed_files = []

    for transcript in transcripts:
        symbol = transcript.get('symbol', 'UNKNOWN').upper()
        quarter = transcript.get('quarter', '?')
        year = transcript.get('year', '?')
        date = transcript.get('date', 'Unknown date')
        content = transcript.get('content', '')

        # Auto-generate output path if not provided
        if not output_path:
            symbol_lower = symbol.lower()
            period = f"{year}-Q{quarter}"
            output_file = json_file.parent / f"{symbol_lower}-earnings-{period}.txt"
        else:
            output_file = Path(output_path)

        # Write formatted transcript
        with open(output_file, 'w') as f:
            f.write(f"{'='*80}\n")
            f.write(f"{symbol} Earnings Call Transcript\n")
            f.write(f"Quarter: Q{quarter} {year}\n")
            f.write(f"Date: {date}\n")
            f.write(f"Source: Financial Modeling Prep\n")
            f.write(f"Processed: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}\n")
            f.write(f"{'='*80}\n\n")
            f.write(content)

        print(f"✓ Created: {output_file}", file=sys.stderr)
        processed_files.append(str(output_file))

    # Return paths as JSON array
    print(json.dumps({
        "success": True,
        "files": processed_files
    }))

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: process-transcript.py <json_file> [output_file]", file=sys.stderr)
        sys.exit(1)

    json_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    try:
        process_transcript(json_path, output_path)
    except Exception as e:
        print(json.dumps({
            "success": False,
            "error": str(e)
        }), file=sys.stderr)
        sys.exit(1)
