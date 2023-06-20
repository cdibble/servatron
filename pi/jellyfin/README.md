# JellyFin Server

Media server for movies, shows, and music (and theoretically more? I guess?)

## Video Manipulation with ffmpeg

```bash
VID_DIR=/path/to/local/media
MOVIE_NAME="Example" # we'd pick up Example_1.avi and Example_2.avi
ls $VID_DIR | grep $MOVIE_NAME | while read each; do echo "file '$VID_DIR/$each'" >> "movie_parts.txt"; done
ffmpeg -f concat -safe 0 -i movie_parts.txt -c copy $MOVIE_NAME.avi
```
