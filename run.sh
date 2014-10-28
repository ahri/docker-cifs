#!/bin/sh

set -ue

name=$(cat NAME)
version=$(cat VERSION)

docker run -d \
    --name cifs \
    --restart="always" \
    -p 139:139 -p 445:445 \
    -e LOGGLY_CUSTOMER_TOKEN=`read -p "Loggly customer token: " token && echo \$token` \
    -e LOGGLY_TAG=`read -p "Loggly tag: " tag && echo \$tag` \
    -v /mnt/media:/mnt/media \
    --volumes-from torrent \
    $name:$version \
    \
    playtime optitron \
    /mnt/media:share:r \
    /torrent/download:download:r
