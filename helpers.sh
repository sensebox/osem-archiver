#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

dav_mkdir () {
  if [ -z "$1" ]
  then
    echo "-dav_mkdir: Parameter #1 is zero length.-"
  else
    echo "Creating folder $ARCHIVE_FOLDER/$1 .."
    curl --silent --fail --retry 5 --retry-delay 10 --user "$DAV_USER:$DAV_PASS" "$DAV_URL/$ARCHIVE_FOLDER/$1" -XMKCOL || ( echo "Creating folder $DAV_URL/$ARCHIVE_FOLDER/$1 failed after 5 retries" && exit 1)
  fi
}

dav_upload () {
  if [ -z "$1" ]
  then
    echo "-dav_upload: Parameter #1 is zero length.-"
  else
    echo "Uploading file $ARCHIVE_FOLDER/$1 .."
    curl --silent --fail --retry 5 --retry-delay 10 --user "$DAV_USER:$DAV_PASS" "$DAV_URL/$ARCHIVE_FOLDER/$1" -XPUT --upload-file - || ( echo "uploading file $DAV_URL/$ARCHIVE_FOLDER/$1 failed after 5 retries" && exit 1)
  fi
}

mongo_export () {
  mongoexport -h "$MONGO_HOST" -d "$MONGO_DB" -u "$MONGO_USER" -p "$MONGO_PASS" --quiet "$@"
}

mongo_export_measurements () {
  if [ -z "$1" ]
  then
    echo "-mongo_export_measurements: Parameter #1 is zero length.-"
  else
    mongo_export -c measurements --fields createdAt,value --type csv --query "{sensor_id: ObjectId(\"$1\"), createdAt: { \$gte: new Date(\"$ARCHIVE_FROM\"), \$lte: new Date(\"$ARCHIVE_TO\") } }" --sort '{createdAt:1}' "${@:2}"
  fi
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
