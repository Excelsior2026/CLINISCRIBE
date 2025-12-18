#!/usr/bin/env python3
"""
CliniScribe Python Client Example

This script demonstrates how to use the CliniScribe API from Python.
Perfect for batch processing multiple lecture recordings!

Usage:
    python client_example.py my_lecture.mp3
    python client_example.py --subject anatomy --ratio 0.2 lecture.mp3
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Optional

import requests


class CliniScribeClient:
    """Simple client for CliniScribe API."""
    
    def __init__(self, base_url: str = "http://localhost:8080"):
        self.base_url = base_url.rstrip("/")
        self.api_url = f"{self.base_url}/api"
    
    def health_check(self) -> dict:
        """Check if the API is running and healthy."""
        response = requests.get(f"{self.api_url}/health")
        return response.json()
    
    def transcribe(self, 
                   audio_file: Path, 
                   ratio: float = 0.15,
                   subject: Optional[str] = None) -> dict:
        """
        Transcribe and summarize an audio file.
        
        Args:
            audio_file: Path to audio file
            ratio: Summary length ratio (0.05-1.0)
            subject: Optional subject (e.g., 'anatomy', 'pharmacology')
            
        Returns:
            Dictionary with transcript, summary, and metadata
        """
        if not audio_file.exists():
            raise FileNotFoundError(f"Audio file not found: {audio_file}")
        
        params = {"ratio": ratio}
        if subject:
            params["subject"] = subject
        
        with open(audio_file, "rb") as f:
            files = {"file": (audio_file.name, f, "audio/mpeg")}
            response = requests.post(
                f"{self.api_url}/pipeline",
                params=params,
                files=files
            )
        
        response.raise_for_status()
        return response.json()


def save_results(result: dict, output_dir: Path):
    """Save transcription and summary to files."""
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Save full result as JSON
    with open(output_dir / "full_result.json", "w") as f:
        json.dump(result, f, indent=2)
    
    # Save transcript
    with open(output_dir / "transcript.txt", "w") as f:
        f.write(result["transcript"]["text"])
    
    # Save summary (formatted notes)
    with open(output_dir / "study_notes.md", "w") as f:
        f.write(f"# Study Notes\n\n")
        f.write(f"**Source**: {result['metadata']['filename']}\n")
        f.write(f"**Duration**: {result['metadata']['duration']:.1f} seconds\n")
        f.write(f"**Language**: {result['metadata']['language']}\n\n")
        f.write("---\n\n")
        f.write(result["summary"])
    
    print(f"\n✅ Results saved to: {output_dir}")
    print(f"   - full_result.json (complete API response)")
    print(f"   - transcript.txt (full transcription)")
    print(f"   - study_notes.md (formatted study notes)")


def main():
    parser = argparse.ArgumentParser(
        description="CliniScribe - Transcribe and summarize medical lectures",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        "audio_file",
        type=Path,
        help="Path to audio file to process"
    )
    
    parser.add_argument(
        "--url",
        default="http://localhost:8080",
        help="CliniScribe API URL (default: http://localhost:8080)"
    )
    
    parser.add_argument(
        "--ratio",
        type=float,
        default=0.15,
        help="Summary length ratio, 0.05-1.0 (default: 0.15)"
    )
    
    parser.add_argument(
        "--subject",
        help="Subject/topic (e.g., 'anatomy', 'pharmacology')"
    )
    
    parser.add_argument(
        "--output",
        type=Path,
        help="Output directory (default: <audio_file>_output)"
    )
    
    parser.add_argument(
        "--no-save",
        action="store_true",
        help="Don't save results to files, just print to console"
    )
    
    args = parser.parse_args()
    
    # Validate ratio
    if not 0.05 <= args.ratio <= 1.0:
        print("❌ Error: ratio must be between 0.05 and 1.0")
        sys.exit(1)
    
    # Initialize client
    client = CliniScribeClient(args.url)
    
    # Check health
    print(f"Checking API health at {args.url}...")
    try:
        health = client.health_check()
        if health["status"] != "healthy":
            print(f"⚠️  Warning: API is in '{health['status']}' state")
            if not health["whisper"]["loaded"]:
                print("   - Whisper model not loaded")
            if not health["ollama"]["available"]:
                print("   - Ollama service not available")
    except Exception as e:
        print(f"❌ Error: Cannot connect to API at {args.url}")
        print(f"   {e}")
        sys.exit(1)
    
    print(f"\n🎙️  Processing: {args.audio_file.name}")
    print(f"   Ratio: {args.ratio}")
    if args.subject:
        print(f"   Subject: {args.subject}")
    
    # Process audio
    try:
        result = client.transcribe(
            args.audio_file,
            ratio=args.ratio,
            subject=args.subject
        )
        
        if not result.get("success"):
            print(f"\n❌ Error: {result.get('message', 'Unknown error')}")
            sys.exit(1)
        
        # Print basic info
        metadata = result["metadata"]
        print(f"\n✅ Processing complete!")
        print(f"   Duration: {metadata['duration']:.1f} seconds")
        print(f"   Language: {metadata['language']}")
        print(f"   Segments: {metadata['segments']}")
        
        # Save or print results
        if args.no_save:
            print("\n" + "="*60)
            print("SUMMARY")
            print("="*60)
            print(result["summary"])
            print("\n" + "="*60)
            print("TRANSCRIPT (first 500 chars)")
            print("="*60)
            print(result["transcript"]["text"][:500] + "...")
        else:
            output_dir = args.output or Path(f"{args.audio_file.stem}_output")
            save_results(result, output_dir)
        
    except requests.exceptions.RequestException as e:
        print(f"\n❌ API request failed: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
