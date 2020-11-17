#!/bin/bash

# Execute in the parent directory where all module directories reside
# This script is quick, dirty and just useful to rapidly create a bunch of files

while read -u 6 LINE
  do
    SYSTEMD="folio-buildhelpers/$(echo "$LINE" | cut -d "/" -f 1 -s)"
    echo -e "WantedBy=folio-okapi@.service\nWantedBy=folio-okapi.service" > $SYSTEMD.tmp
    while read -u 5 PROVIDES
      do
        if [ "${PROVIDES:0:1}" = "_" -o "$PROVIDES" = "" ]
          then
            continue
        fi
        while read -u 7 FILE
          do
            if [ "$FILE" = "" ]
              then
                continue
            fi
            echo -e "WantedBy=$FILE" >> $SYSTEMD.tmp
          done 7<<<$(grep "$PROVIDES " folio-buildhelpers/apis_required.list | cut -d " " -f 2 -s)
      done 5<<<$(folio-buildhelpers/get_apis.py -i $LINE -p) 
    sort -u $SYSTEMD.tmp > $SYSTEMD.dep_passive
    rm $SYSTEMD.tmp
  done 6<<<$(ls -1 folio-mod-*/orig-packaging/module_descriptor.json)
