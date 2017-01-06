#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

#include config and helper functions
source config
source helpers.sh

while getopts ":-date" opt; do
  case $opt in
    a)
      echo "-a was triggered!" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# set up some date strings
FOLDER_NAME=$(date -u --date 'yesterday' +%F)
ARCHIVE_FROM=$(printf %s "$FOLDER_NAME" "T00:00:00.000Z")
ARCHIVE_TO=$(printf %s "$FOLDER_NAME" "T23:59:59.999Z")

# create base folder on the server
dav_mkdir "$FOLDER_NAME"

# query boxes from database
BOXES_RAW=$(mongoexport --host db --db OSeM-api -c boxes --quiet --jsonArray -f sensors)

# extract just the ids from $BOXES_RAW then
echo "$BOXES_RAW" | jq -r '.[]._id | .["$oid"]' | while read -r boxid ; do
  # create folder for this box
  dav_mkdir "$FOLDER_NAME/$boxid"
  # iterate over sensor ids
  echo "$BOXES_RAW" | jq -r ".[] | select((._id | .[\"\$oid\"])==\"$boxid\") | .sensors[]._id | .[\"\$oid\"]" | while read -r sensor_id ; do
    #dav_mkdir "$FOLDER_NAME/$boxid/$sensor_id"
    mongoexport --host db --db OSeM-api -c measurements --quiet --fields createdAt,value --type csv --query "{sensor_id: ObjectId(\"$sensor_id\"), createdAt: { \$gte: new Date(\"$ARCHIVE_FROM\"), \$lte: new Date(\"$ARCHIVE_TO\") } }" | dav_upload "$FOLDER_NAME/$boxid/$sensor_id.csv"
  done
done

