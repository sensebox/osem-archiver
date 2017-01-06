#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

dav_mkdir () {
  if [ -z "$1" ]
  then
    echo "-dav_mkdir: Parameter #1 is zero length.-"
  else
    curl --user "$DAV_USER:$DAV_PASS" "$DAV_URL/$ARCHIVE_FOLDER/$1" -XMKCOL
  fi
}

dav_upload () {
  if [ -z "$1" ]
  then
    echo "-dav_upload: Parameter #1 is zero length.-"
  else
    curl --user "$DAV_USER:$DAV_PASS" "$DAV_URL/$ARCHIVE_FOLDER/$1" -XPUT --upload-file -
  fi
}
