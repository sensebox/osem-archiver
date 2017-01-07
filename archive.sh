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

echo "Going to backup data from $ARCHIVE_FROM until $ARCHIVE_TO"

# create base folder on the server
dav_mkdir "$FOLDER_NAME"

# query boxes from database
BOXES_RAW=$(mongo_export -c boxes --jsonArray -f sensors,name,boxType,exposure,model,loc)

# extract just the ids from $BOXES_RAW then
echo "$BOXES_RAW" | jq_boxids | while read -r boxid ; do
  # extract box name (id-name) from $BOXES_RAW
  BOX_NAME=$(echo "$BOXES_RAW" | jq_box_name "$boxid")

  FOLDER_CREATED=false

  # iterate over sensor ids
  echo "$BOXES_RAW" | jq_box_sensorids "$boxid" | while read -r sensor_id ; do
    # check if this sensor has measurements
    if [ "$(mongo_export_measurements "$sensor_id" --limit 1 | wc -l)" -eq 2 ]
    then
      # check if folder is created
      if [ "$FOLDER_CREATED" = false ]
      then
        # create folder for this box
        dav_mkdir "$FOLDER_NAME/$BOX_NAME"

        # create json file with box information
        echo "$BOXES_RAW" | jq_box_json "$boxid" | dav_upload "$FOLDER_NAME/$BOX_NAME/$BOX_NAME.json"
        FOLDER_CREATED=true
      fi

      # data is avaliable. upload it
      mongo_export_measurements "$sensor_id" | dav_upload "$FOLDER_NAME/$BOX_NAME/$sensor_id.csv"
    fi
  done
done

