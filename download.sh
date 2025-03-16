#!/bin/bash
set -e

# --- Dependency Checks ---
if ! command -v soundcloud-dl &> /dev/null; then
    echo "Error: soundcloud-dl is not installed. Please install it and ensure it's in your PATH."
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it to enable mp3 conversion."
    exit 1
fi

# --- Argument Parsing ---
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <soundcloud_playlist_url> [--keep-original] [--convert-only] [--verbose]"
    exit 1
fi

PLAYLIST_URL="$1"
REMOVE_ORIGINAL=true
CONVERT_ONLY=false
VERBOSE=false

# Process optional arguments
shift  # Remove URL from the argument list
for arg in "$@"; do
    case "$arg" in
        --keep-original)
            REMOVE_ORIGINAL=false
            ;;
        --convert-only)
            CONVERT_ONLY=true
            ;;
        --verbose)
            VERBOSE=true
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

# --- Setup Download Path ---
playlist_name=$(basename "$PLAYLIST_URL")
playlist_name="${playlist_name%%\?*}"

BASE_DOWNLOAD_PATH="$HOME/Music/soundcloud"
DOWNLOAD_PATH="$BASE_DOWNLOAD_PATH/$playlist_name"
mkdir -p "$DOWNLOAD_PATH"

if $VERBOSE; then
    echo "Playlist URL: $PLAYLIST_URL"
    echo "Download directory: $DOWNLOAD_PATH"
fi

# --- Download Step (if not --convert-only) ---
if [ "$CONVERT_ONLY" = false ]; then
    $VERBOSE && echo "Downloading playlist using soundcloud-dl..."
    soundcloud-dl -b -p "$DOWNLOAD_PATH" "$PLAYLIST_URL"
    $VERBOSE && echo "Download completed."
else
    $VERBOSE && echo "Skipping download step. Proceeding with conversion in directory: $DOWNLOAD_PATH"
fi

echo "Starting conversion to MP3 (if needed)..."

# --- Prepare Conversion ---
shopt -s nullglob

# Build an array of files that need conversion (non-MP3 files)
to_convert=()
for file in "$DOWNLOAD_PATH"/*; do
    ext="${file##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    if [ "$ext_lower" != "mp3" ]; then
        to_convert+=("$file")
    fi
done

total=${#to_convert[@]}
counter=0

if $VERBOSE; then
    echo "Found $total file(s) to convert."
fi

# --- Conversion Loop ---
for file in "${to_convert[@]}"; do
    ((counter++))
    # --- Extract Metadata using ffprobe ---
    get_tag() {
      ffprobe -v quiet -show_entries format_tags="$1" -of default=nw=1:nk=1 "$file" || echo ""
    }
    artist=$(get_tag "artist")
    title=$(get_tag "title")
    remixer=$(get_tag "remixer")
    genre=$(get_tag "genre")

    # Fallback defaults if missing.
    artist=${artist:-Unknown}
    title=${title:-Unknown}
    genre=${genre:-Unknown}

    # --- Build the output filename with smart logic ---
    # Convert both artist and title to lowercase for comparison.
    lc_artist=$(echo "$artist" | tr '[:upper:]' '[:lower:]')
    lc_title=$(echo "$title" | tr '[:upper:]' '[:lower:]')
    
    # If title starts with the artist name, remove it along with a possible dash.
    if [[ "$lc_title" == "$lc_artist"* ]]; then
       title_without_artist="${title:${#artist}}"
       # Remove any leading spaces and dash.
       title_without_artist=$(echo "$title_without_artist" | sed 's/^[[:space:]]*-[[:space:]]*//')
    else
       title_without_artist="$title"
    fi

    # Build base filename: if artist was already in the title, don't duplicate.
    if [[ "$lc_title" == "$lc_artist"* ]]; then
        base_filename="$title_without_artist"
    else
        base_filename="$artist - $title"
    fi

    if [ -n "$remixer" ]; then
        new_filename="${base_filename} (${remixer}).mp3"
    else
        new_filename="${base_filename}.mp3"
    fi
    output="$DOWNLOAD_PATH/$new_filename"

    if $VERBOSE; then
        echo "Processing file ($counter/$total): $file"
        echo "Converting to: $output"
    else
        # Minimal output: just the target filename and progress.
        echo "$new_filename ($counter/$total processed)"
    fi

    # --- Conversion with FFmpeg ---
    if [ -n "$remixer" ]; then
      ffmpeg -i "$file" \
        -map "0:a" -map "0:v?" \
        -c:v copy -c:a libmp3lame -q:a 0 \
        -id3v2_version 3 \
        -metadata "artist=$artist" \
        -metadata "title=$title" \
        -metadata "genre=$genre" \
        -metadata "remixer=$remixer" \
        "$output" -y >/dev/null 2>&1
    else
      ffmpeg -i "$file" \
        -map "0:a" -map "0:v?" \
        -c:v copy -c:a libmp3lame -q:a 0 \
        -id3v2_version 3 \
        -metadata "artist=$artist" \
        -metadata "title=$title" \
        -metadata "genre=$genre" \
        "$output" -y >/dev/null 2>&1
    fi

    $VERBOSE && echo "Conversion completed for $file."

    if $REMOVE_ORIGINAL; then
        rm "$file"
        $VERBOSE && echo "Removed original file: $file"
    fi
done

echo "All conversions completed."
