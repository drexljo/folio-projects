#!/bin/bash

# Get parameter 1 (package name)
PACKAGE="$1"

INFILE="$BH_BINPATH/$PACKAGE/okapi-test-module/target/ModuleDescriptor.json"
OUTFILE="module_descriptor.json"

# Execute the ModuleDescriptor.json modifying script 'prep_moduledescriptors.py'
# from the folio-buildhelpers directory
../../folio-buildhelpers/prep_md.py -i "$INFILE" -o "$OUTFILE" > /dev/null 2>&1 \
  && sed -i 's/test-basic-/mod-test-/g' "$OUTFILE" \
  && git add "$OUTFILE"

exit "$?"
