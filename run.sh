#!/bin/sh

docker run -d \
    --name smb \
    --restart="always" \
    -p 139:139 -p 445:445 \
    -v /mnt/media:/mnt/media \
    --volumes-from torrent \
    ahri/samba \
    \
    playtime optitron \
    /mnt/media:share:r \
    /torrent/download:download:r
