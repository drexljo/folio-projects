#!/bin/bash

# Execute in the parent directory where all module directories reside
# This script is quick, dirty and just useful to rapidly create a bunch of files

# Set hard variables
PROV_FILE="folio-buildhelpers/apis_provided.list"
REQ_FILE="folio-buildhelpers/apis_required.list"

# Read directory
while read -u 6 DIRECTORY
  do
    # Set variables for this directory
    TMP_SRVC="folio-buildhelpers/$DIRECTORY.tmp_srvc"
    TMP_TRGT="folio-buildhelpers/$DIRECTORY.tmp_trgt"
    SERVICEFILE="$DIRECTORY/orig-packaging/$DIRECTORY@.service"
    TARGETFILE="$DIRECTORY/orig-packaging/$DIRECTORY.target"
    # Check for existing service file
    if [ ! -f "$SERVICEFILE" ]
      then
        echo "Can't find service file '$SERVICEFILE'."
        continue
    fi
    # Begin writing systemd files
    echo "[Unit]" > "$TMP_SRVC"
    echo "[Unit]" > "$TMP_TRGT"
    # Fetch description from service file
    grep "Description" "$SERVICEFILE" >> "$TMP_SRVC"
    grep "Description" "$SERVICEFILE" >> "$TMP_TRGT"
    # Change "service" to "target" for the target file
    sed -i 's/service/target/g' "$TMP_TRGT"
    # Write mutual head statements
    echo -e "PartOf=$DIRECTORY.target\nAfter=folio-okapi.target\nAfter=network-online.target\nAfter=postgres.service\nRequires=network-online.target\nWants=folio-okapi.target\nWants=postgres.service" >> "$TMP_SRVC"
    # Find out requirements for the module of this directory by parsing the
    # API requirements file
    if REQUIRES="$(grep -E " $DIRECTORY$" "$REQ_FILE")"
      then
        PROVIDED_BY=""
        # Cut the module name from the list
        REQUIRES="$(echo -e "$REQUIRES" | cut -d " " -f 1)"
        # Write explanation statement to service file
        echo "# Folio module dependencies" >> "$TMP_SRVC"
        # Read requirements and find the providing module names
        while read -u 7 REQUIREMENT
          do
            if [ "$REQUIREMENT" != "" ]
              then
                # Gather all provider modules in one variable
                PROVIDED_BY="$(echo -e "$PROVIDED_BY\n$(grep -E "^$REQUIREMENT " "$PROV_FILE" | cut -d " " -f 2)")"
            fi
          done 7<<<$(echo "$REQUIRES" | sort -u)
        # Write provider targets to service file
        while read -u 7 PROVIDES
          do
            if [ "$PROVIDES" != "" ]
              then
                # Write it in after and wants statements
                echo -e "After=$PROVIDES.target\nWants=$PROVIDES.target" >> "$TMP_SRVC" 
            fi
          # Sort the provider modules list and kill duplicates, then parse it
          done 7<<<$(echo "$PROVIDED_BY" | sort -u)
    fi
    # Print a newline to both systemd files
    echo "" >> "$TMP_SRVC"
    echo "" >> "$TMP_TRGT"
    # Import everything within the service section of the old service unit to
    # the new one
    grep -A 200 "\[Service\]" "$SERVICEFILE" | grep -B 200 "\[Install\]" >> "$TMP_SRVC"
    # Write the install sections
    echo "[Install]" >> "$TMP_TRGT"
    echo "WantedBy=$DIRECTORY.target" >> "$TMP_SRVC"
    echo "WantedBy=multi-user.target" >> "$TMP_TRGT"
    # Move both systemd file to the target directory and add to git
    mv "$TMP_SRVC" "$SERVICEFILE"
    git add "$SERVICEFILE"
    mv "$TMP_TRGT" "$TARGETFILE"
    git add "$TARGETFILE"
  # Only work on folio-mods
  done 6<<<$(ls -1 | grep "folio-mod-")
