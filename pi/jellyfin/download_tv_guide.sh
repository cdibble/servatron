#!/bin/bash
ZAPUSER=*********************
ZAPPW=*********************
docker run -d --name zap2xml -v /xmltvdata:/data --restart "unless-stopped" -e USERNAME=$ZAPUSER -e PASSWORD=$ZAPPW -e OPT_ARGS="-I -D -Z 92103" -e XMLTV_FILENAME=xmltv.xml cddibble/zap2xml

