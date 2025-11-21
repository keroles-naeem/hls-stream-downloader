#!/bin/bash
set -euo pipefail

for idx in {1..8}; do
  manifest="${idx}.m3u8"

  # Download Arabic and English audio/subtitles for each manifest
  grep -E '#EXT-X-MEDIA:TYPE=(AUDIO|SUBTITLES)' "$manifest" | \
  grep -E 'NAME="Arabic"|NAME="English"' | \
  while IFS= read -r line; do
    name=$(echo "$line" | sed -nE 's/.*NAME="([^"]*)".*/\1/p' | tr ' ' '_')
    url=$(echo "$line" | sed -nE 's/.*URI="([^"]*)".*/\1/p')
    
    echo "Downloading ${name} from ${url} (segment ${idx})"
    
    if [[ "$line" =~ TYPE=AUDIO ]]; then
      yt-dlp -o "${idx}_${name}.m4a" "$url"
    elif [[ "$line" =~ TYPE=SUBTITLES ]]; then
      yt-dlp -o "${idx}_${name}.vtt" "$url"
    fi
  done

  # Capture the video URL with resolution 1280x720 from the manifest
  video_url=$(
    awk -v RS='#EXT-X-STREAM-INF' -v FS='\n' '
      $1 ~ /RESOLUTION=1280x720/ { print $2 }
    ' "$manifest" | head -n 1
  )

  echo "Downloading video stream from ${video_url} (segment ${idx})"
  yt-dlp -o "${idx}.mp4" "$video_url"

  # Merge video with audio and subtitles using ffmpeg
  ffmpeg -i "${idx}.mp4" \
         -i "${idx}_Arabic.m4a" -i "${idx}_English.m4a" \
         -i "${idx}_Arabic.vtt" -i "${idx}_English.vtt" \
         -map 0:v:0 \
         -map 1:a:0 -map 2:a:0 \
         -map 3 -map 4 \
         -c:v copy -c:a aac -c:s mov_text \
         -metadata:s:a:0 language=ar -metadata:s:a:1 language=en \
         -metadata:s:s:0 language=ar -metadata:s:s:1 language=en \
         "${idx}_final.mp4"

  # Cleanup temporary files for each segment
  rm -f "${idx}_Arabic.m4a" "${idx}_English.m4a" \
        "${idx}_Arabic.vtt" "${idx}_English.vtt" "${idx}.mp4"

  echo "Cleanup done. Final segment output: ${idx}_final.mp4"

done

