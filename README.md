# HLS Stream Downloader

This repository contains a Bash script to automate downloading Arabic and English audio and subtitle streams along with a video stream from an HLS (`m3u8`) manifest using `yt-dlp`. It then merges the downloaded streams into a single MP4 file tagged with language metadata using `ffmpeg`.

## Features

- Extracts Arabic and English audio and subtitle stream URLs from an HLS manifest.
- Downloads all streams with descriptive filenames.
- Downloads video stream of specified resolution.
- Merges audio, video, and subtitle streams into one output MP4.
- Tags audio and subtitle streams with proper language metadata.
- Cleans up intermediate files, keeping only the final output.
- Supports interactive input for output filename.

## Requirements

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [ffmpeg](https://ffmpeg.org/)
- Bash shell environment

## Usage

1. Place your HLS manifest file (`hls.m3u8`) in the same directory as the script or update the script to point to your manifest location.
2. Run the script:

