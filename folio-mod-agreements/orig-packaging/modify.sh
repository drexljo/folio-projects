#!/bin/bash

# Get parameter 1 (package name)
PACKAGE="$1"

INFILE="$BH_BINPATH/$PACKAGE/service/build/resources/main/okapi/ModuleDescriptor.json"
OUTFILE="module_descriptor.json"

# Execute the ModuleDescriptor.json modifying script 'prep_moduledescriptors.py'
# from the folio-buildhelpers directory
../../folio-buildhelpers/prep_md.py -i "$INFILE" -o "$OUTFILE" > /dev/null 2>&1 \
  && git add "$OUTFILE"

exit "$?"
