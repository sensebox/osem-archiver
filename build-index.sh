#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# set date to backup
BACKUP_DATE=''

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

if [ -z "$BACKUP_DATE" ]; then
  echo "no date specified"
  exit 1
fi

GITHUB_URL="https://${GITHUB_ACCESS_TOKEN}@github.com/${GITHUB_REPO}.git"

# clone the repo for the html
git -C html_folder pull --quiet || git clone --quiet -b "$GIT_BRANCH" "$GITHUB_URL" html_folder

# update the index
curl --fail --silent --retry 5 --retry-delay 10 --user "$DAV_PUBLIC_USER:" -XPROPFIND "$DAV_PUBLIC_URL" -H "Depth: 1" -d '<?xml version="1.0"?><d:propfind  xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns"><d:prop><d:getlastmodified /><d:resourcetype /><oc:size /></d:prop></d:propfind>' | xsltproc style_root.xslt - | sed -r 's/(Mon|Tue|Wed|Thu|Fri|Sat|Sun), ([0-9]{2}) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ([0-9]{4}) ([0-9]{2}:[0-9]{2}:[0-9]{2}) GMT/\2-\3-\4 \5/' > html_folder/index.html

# create index.html for specified date folder
mkdir -p "html_folder/$BACKUP_DATE"

# fetch subdirs of current date
BOXES=$(curl --fail --silent --retry 5 --retry-delay 10 --user "$DAV_PUBLIC_USER:" -XPROPFIND "$DAV_PUBLIC_URL/$BACKUP_DATE" -H "Depth: 1" -d '<?xml version="1.0"?><d:propfind  xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns"><d:prop><d:getlastmodified /><d:resourcetype /><oc:size /></d:prop></d:propfind>')

# create index for current date
echo -n "$BOXES" | xsltproc style_datefolder.xslt - | sed -r 's/(Mon|Tue|Wed|Thu|Fri|Sat|Sun), ([0-9]{2}) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ([0-9]{4}) ([0-9]{2}:[0-9]{2}:[0-9]{2}) GMT/\2-\3-\4 \5/' > "html_folder/$BACKUP_DATE/index.html"

# create subfolders
while read -r box ; do
  # create box folder
  mkdir -p "html_folder/$BACKUP_DATE/$box"
  # pull contents of box folder
    curl --fail --silent --retry 5 --retry-delay 10 --user "$DAV_PUBLIC_USER:" -XPROPFIND "$DAV_PUBLIC_URL/$BACKUP_DATE/$box" -H "Depth: 1" -d '<?xml version="1.0"?><d:propfind  xmlns:d="DAV:"><d:prop><d:getlastmodified /><d:resourcetype /><d:getcontentlength /></d:prop></d:propfind>' | xsltproc style_boxfolder.xslt - | sed -r 's/(Mon|Tue|Wed|Thu|Fri|Sat|Sun), ([0-9]{2}) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) ([0-9]{4}) ([0-9]{2}:[0-9]{2}:[0-9]{2}) GMT/\2-\3-\4 \5/' > html_folder/$BACKUP_DATE/$box/index.html
done <<< "$(echo -n "$BOXES" | xsltproc extract_boxes.xslt - | tr "/" "\n")"

# stage, commit and push
cd html_folder
# tell git who you are
git config user.name "osem-archiver"
git config user.email "no-reply@sensebox.de"

git add -A
git commit --quiet -m "update html to add $BACKUP_DATE"
git push --quiet "$GITHUB_URL" "$GIT_BRANCH"
