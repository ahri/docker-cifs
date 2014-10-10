#!/bin/sh
name="ahri/base"
version=$(cat VERSION)

tag="$name:$version"
docker push $tag
docker push $name:latest
