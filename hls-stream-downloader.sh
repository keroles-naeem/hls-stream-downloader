#!/bin/bash

# Prompt user for output file name
read -p "Enter output file name (without extension): " output_name

# Download Arabic and English audio/subtitles
grep -E '#EXT-X-MEDIA:TYPE=(AUDIO|SUBTITLES)' hls.m3u8 | \
grep -E 'NAME="Arabic"|NAME="English"' | \
while IFS= read -r line; do
  name=$(echo "$line" | sed -nE 's/.*NAME="([^"]*)".*/\1/p' | tr ' ' '_')
  url=$(echo "$line" | sed -nE 's/.*URI="([^"]*)".*/\1/p')
  echo "Downloading $name from $url"
  if [[ "$line" =~ TYPE=AUDIO ]]; then
    yt-dlp -o "${name}.m4a" "$url"
  elif [[ "$line" =~ TYPE=SUBTITLES ]]; then
    yt-dlp -o "${name}.vtt" "$url"
  fi
done

# Capture the video URL with resolution 1280x720 from the manifest
video_url=$(grep -A1 '#EXT-X-STREAM-INF' hls.m3u8 | grep -B1 'RESOLUTION=1280x720' | grep -v '#EXT-X-STREAM-INF' | sed -nE 's/^(.+)/\1/p')

echo "Downloading video stream from $video_url"
yt-dlp -o "video.%(ext)s" "$video_url"


# Merge video with audio and subtitles using ffmpeg
ffmpeg -i video.mp4 \
       -i Arabic.m4a -i English.m4a \
       -i Arabic.vtt -i English.vtt \
       -map 0:v:0 \
       -map 1:a:0 -map 2:a:0 \
       -map 3 -map 4 \
       -c:v copy -c:a aac -c:s mov_text \
       -metadata:s:a:0 language=ar -metadata:s:a:1 language=en \
       -metadata:s:s:0 language=ar -metadata:s:s:1 language=en \
       "${output_name}.mp4"
# Remove all temporary files except the final output
rm -f video.* Arabic.* English.*

echo "Cleanup done. Final output: ${output_name}.mp4"
