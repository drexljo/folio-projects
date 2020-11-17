#!/bin/bash

# Get parameter 1 (package name)
PACKAGE="$1"

INFILE="$BH_BINPATH/$PACKAGE/target/ModuleDescriptor.json"
OUTFILE="module_descriptor.json"

# Execute the ModuleDescriptor.json modifying script 'prep_moduledescriptors.py'
# from the folio-buildhelpers directory
../../folio-buildhelpers/prep_md.py -i "$INFILE" -o "$OUTFILE" > /dev/null 2>&1 \
  && git add "$OUTFILE"

if [ "$?" = "0" ]
  then
    # Copy the uniquely named relevant jar to standardized name
    SRCNAME=$(grep "\"id\":" $BH_BINPATH/$PACKAGE/target/Activate.json | cut -d '"' -f 4)
    cp "$BH_BINPATH/$PACKAGE/target/${SRCNAME}.jar" "$BH_BINPATH/$PACKAGE/target/mod-circulation-fat.jar"
fi

exit "$?"
