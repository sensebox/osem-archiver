#!/bin/bash

set -euo pipefail
IFS=$'\n\t'


d=2014-02-20
while [ "$d" != 2017-01-09 ]; do
  echo $d
  d=$(date -I -d "$d + 1 day")

  ./archive.sh -d "$d"

  sleep 10

done
