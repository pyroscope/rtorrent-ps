#! /usr/bin/env bash
#
# Upload DEB package files to Bintray
#
set -e

# Config / constants
BINTRAY_ACCOUNT="pyroscope"
BINTRAY_PROJECT="rtorrent-ps"
BASE_URL="https://api.bintray.com"
CURL_BIN=(curl -X PUT -u"$BINTRAY_ACCOUNT":"${BINTRAY_API_KEY:?You MUST set the Bintray API key}" \
               -H Content-Type:application/json -H Accept:application/json )
SHOWFILE_DELAY=10

# Loop over all arguments
for debfile in "$@"; do
    test -f "$debfile" || { echo "$debfile is not a file"; exit 1; }

    # Extract metadata
    filename=${debfile##*/}
    version=$(dpkg-deb -f "$debfile" Version)
    arch=$(dpkg-deb -f "$debfile" Architecture)
    section=$(dpkg-deb -f "$debfile" Section)
    distro=${version##*~}
    version=${version%%~*}

    # Build API URLs
    upload_url="$BASE_URL/content/$BINTRAY_ACCOUNT/${BINTRAY_PROJECT}/${BINTRAY_PROJECT}/$version/$filename"
    upload_url="$upload_url;deb_distribution=$distro;deb_component=${section};deb_architecture=$arch;publish=1"
    showfile_url="$BASE_URL/file_metadata/$BINTRAY_ACCOUNT/${BINTRAY_PROJECT}/$filename"

    # Perform the upload
    echo "Uploading and publishing to $upload_url ..."
    ${CURL_BIN[@]} --progress-bar -T "$debfile" "$upload_url"
    echo

    for i in $(seq ${SHOWFILE_DELAY:-9} -1 1); do echo -ne " $i  "'\r'; sleep 1; done; echo -e '\r     \r'

    echo "Displaying $filename in download list using $showfile_url ..."
    ${CURL_BIN[@]} "$showfile_url" -d '{ "list_in_downloads": true }'
    echo
done

echo
echo "Open ${BASE_URL/api./}/$BINTRAY_ACCOUNT/${BINTRAY_PROJECT}/${BINTRAY_PROJECT}/$version to view upload results."
