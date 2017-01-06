#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

#include config and helper functions
source config
source helpers.sh

# set date to backup
BACKUP_DATE='yesterday'

while getopts ":d:" opt; do
  case $opt in
    d)
      echo "Setting date to: $OPTARG" >&2
      BACKUP_DATE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# set up some date strings
FOLDER_NAME=$(date -u --date "$BACKUP_DATE" +%F)
ARCHIVE_FROM=$(printf %s "$FOLDER_NAME" "T00:00:00.000Z")
ARCHIVE_TO=$(printf %s "$FOLDER_NAME" "T23:59:59.999Z")

# create base folder on the server
dav_mkdir "$FOLDER_NAME"

# query boxes from database
BOXES_RAW=$(mongo_export -c boxes --jsonArray -f sensors,name,boxType,exposure,model,loc)

# extract just the ids from $BOXES_RAW then
echo "$BOXES_RAW" | jq_boxids | while read -r boxid ; do
  # extract box name (id-name) from $BOXES_RAW
  BOX_NAME=$(echo "$BOXES_RAW" | jq_box_name "$boxid")

  # create folder for this box
  dav_mkdir "$FOLDER_NAME/$BOX_NAME"

  # create json file with box information
  echo "$BOXES_RAW" | jq_box_json "$boxid" | dav_upload "$FOLDER_NAME/$BOX_NAME/$BOX_NAME.json"

  # iterate over sensor ids
  echo "$BOXES_RAW" | jq_box_sensorids "$boxid" | while read -r sensor_id ; do
    mongo_export -c measurements --fields createdAt,value --type csv --query "{sensor_id: ObjectId(\"$sensor_id\"), createdAt: { \$gte: new Date(\"$ARCHIVE_FROM\"), \$lte: new Date(\"$ARCHIVE_TO\") } }" | dav_upload "$FOLDER_NAME/$BOX_NAME/$sensor_id.csv"
  done
done

