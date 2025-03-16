# SoundCloud Playlist Downloader & Converter

This Bash script downloads a SoundCloud playlist using [`soundcloud-dl`](https://github.com/) (make sure it's installed and in your PATH), converts the downloaded tracks to MP3 format using FFmpeg (with album art and metadata preserved), and renames the files in a smart way to avoid duplicating the artist name.

## Features

- **Download Tracks:** Downloads all tracks from a provided SoundCloud playlist URL.
- **MP3 Conversion:** Converts non-MP3 files to MP3 format using FFmpeg with best-quality settings.
- **Smart Filename Generation:** Constructs output filenames in the format:
  - `Artist - Title (Remixer).mp3`
  - If the title already starts with the artist’s name, it avoids duplicating the artist.
- **Metadata Tagging:** Writes MP3 tags for artist, title, genre, and remixer.
- **Album Art Preservation:** Copies embedded album art (if present) during conversion.
- **Flexible Options:** Supports flags to keep original files, perform conversion only, and enable verbose output.
- **Progress Display:** Provides a progress counter during conversion when verbose mode is off.

## Prerequisites

Before using this script, ensure you have the following installed and available in your system's PATH:

- [soundcloud-dl](https://github.com/)  
- [FFmpeg](https://ffmpeg.org/)

For example, on macOS you can install FFmpeg via Homebrew:

```bash
brew install ffmpeg
