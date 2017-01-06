#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

dav_mkdir () {
  if [ -z "$1" ]
  then
    echo "-dav_mkdir: Parameter #1 is zero length.-"
  else
    echo "Creating folder $1 .."
    curl --fail --user "$DAV_USER:$DAV_PASS" "$DAV_URL/$ARCHIVE_FOLDER/$1" -XMKCOL
  fi
}

dav_upload () {
  if [ -z "$1" ]
  then
    echo "-dav_upload: Parameter #1 is zero length.-"
  else
    echo "Uploading file $1 .."
    curl --fail --user "$DAV_USER:$DAV_PASS" "$DAV_URL/$ARCHIVE_FOLDER/$1" -XPUT --upload-file -
  fi
}

mongo_export () {
  mongoexport -h "$MONGO_HOST" -d "$MONGO_DB" -u "$MONGO_USER" -p "$MONGO_PASS" --quiet "$@"
}

jq_boxids () {
  jq -r '.[]._id | .["$oid"]'
}

jq_box_json () {
  if [ -z "$1" ]
  then
    echo "-jq_box_json: Parameter #1 is zero length.-"
  else
    jq -r -c -M ".[] | select((._id | .[\"\$oid\"])==\"$1\") | {name,id: (._id | .[\"\$oid\"]),boxType,exposure,model,loc: {geometry:.loc[0].geometry}, sensors: [(.sensors[] | {title, unit, sensorType, id: (._id | .[\"\$oid\"])})] }"
  fi
}

jq_box_sensorids () {
  if [ -z "$1" ]
  then
    echo "-jq_box_sensorids: Parameter #1 is zero length.-"
  else
    jq -r ".[] | select((._id | .[\"\$oid\"])==\"$1\") | .sensors[]._id | .[\"\$oid\"]"
  fi
}

jq_box_name () {
  if [ -z "$1" ]
  then
    echo "-jq_box_name: Parameter #1 is zero length.-"
  else
    jq -r ".[] | select((._id | .[\"\$oid\"])==\"$1\") | [(._id | .[\"\$oid\"]), \"-\", .name] | add" | sed -e 's/[^A-Za-z0-9._-]/_/g'
  fi
}
