# SoundCloud Playlist Downloader and Converter

This bash script downloads a SoundCloud playlist using `soundcloud-dl`, then converts the downloaded tracks to MP3 using `ffmpeg` while embedding metadata and preserving album art. It also builds output filenames in a smart format that avoids duplicate artist names.

## Features

- **Download:** Uses `soundcloud-dl` to download all tracks from a specified SoundCloud playlist.
- **Conversion:** Converts tracks to MP3 using `ffmpeg` with best-quality audio settings.
- **Metadata:** Writes MP3 tags for artist, title, genre, and remixer.
- **Smart Filenames:** Creates output files in the format:
  - `Artist - Title (Remixer).mp3`
  
  If the title already includes the artist name, the script avoids duplicating it.
- **Album Art:** Preserves album art by mapping the video stream.
- **Optional Flags:**
  - `--keep-original`: Keeps the original (non-MP3) file after conversion (default is to remove it).
  - `--convert-only`: Skips the download step and converts files in the existing directory.
  - `--verbose`: Displays detailed progress and conversion information. Without this flag, only the new filename and a progress counter are printed.

## Requirements

- [soundcloud-dl](https://github.com/soundcloud-dl/soundcloud-dl) installed and available in your `PATH`.
- [ffmpeg](https://ffmpeg.org/) installed and available in your `PATH`.
- Bash shell

## Installation

1. **Clone or download** this repository and save the script (e.g. `download_sc_playlist.sh`) to your local machine.
2. **Make the script executable:**
   ```bash
   chmod +x download_sc_playlist.sh
