#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

exec go-cron -p "0" -s "*/1 * * * *" -- /osem-archiver/cron-wrapper.sh /osem-archiver/archive.sh
