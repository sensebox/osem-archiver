#!/bin/bash

#set -euo pipefail
#IFS=$'\n\t'

set -uo pipefail
IFS=$'\n\t'

notify_slack () {
  if [ -n "$SLACK_HOOK_URL" ]
  then
    escapedText=$(echo "$1" | sed 's/"/\"/g' | sed "s/'/\'/g" )
    json="{\"text\": \"Error while running archive script: \`$escapedText\`\"}"

    curl -s -d "payload=$json" "$SLACK_HOOK_URL"
  fi
}

BACKUP_RESULT="$(/bin/bash -c "$1" 2>&1 > /dev/null)"

echo -n "$BACKUP_RESULT" > /osem-archiver/lastrunresult

echo "$BACKUP_RESULT"

if [ -n "$BACKUP_RESULT" ]
then
  notify_slack "$BACKUP_RESULT"
fi

