#!/bin/bash

# Execute in the parent directory where all module directories reside
# This script is quick, dirty and just useful to rapidly create a bunch of files

while read -u 6 LINE
  do
    SYSTEMD="folio-buildhelpers/$(echo "$LINE" | cut -d "/" -f 1 -s)"
    echo -e "After=postgres\nWants=postgres\nAfter=network-online.target\nRequires=network-online.target\nAfter=folio-okapi\nWants=folio-okapi" > $SYSTEMD.tmp
    while read -u 5 REQUIRES 
      do
        if [ "${REQUIRES:0:1}" = "_" -o "$REQUIRES" = "" ]
          then
            continue
        fi
        while read -u 7 FILE
          do
            if [ "$FILE" = "" ]
              then
                continue
            fi
            echo -e "After=$FILE\nWants=$FILE" >> $SYSTEMD.tmp
          done 7<<<$(grep "$REQUIRES " folio-buildhelpers/apis.list | cut -d " " -f 2 -s | cut -d "@" -f 1 -s)
      done 5<<<$(folio-buildhelpers/get_apis.py -i $LINE -r) 
    sort -u $SYSTEMD.tmp > $SYSTEMD.dep_active
    rm $SYSTEMD.tmp
  done 6<<<$(ls -1 folio-mod-*/orig-packaging/module_descriptor.json)
