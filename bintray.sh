#! /bin/bash
path="$1"
test -f "$path" || { echo "You must provide a package file"; exit 1; }

file=$(basename "$path")
vers=$(cut -f2 -d_ <<<"$file")
vers=${vers%%~*}
url="https://api.bintray.com/content/pyroscope/rtorrent-ps/rtorrent-ps/$vers/$file"

echo "Uploading to $url..." 
curl -# -T "$path" -u$BINTRAY_ACCOUNT:$BINTRAY_API_KEY "$url"

