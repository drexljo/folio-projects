#!/usr/bin/python3

# Import modules
import argparse
import json
import os

# Handle parameters
param_parser = argparse.ArgumentParser(description='Modify JSON file by removing the launch descriptor.')
param_parser.add_argument("--infile", "-i", action="store", dest="infile", help="File to work on")
param_parser.add_argument("--outfile", "-o", action="store", dest="outfile", help="File to spit out")
args = param_parser.parse_args()

# Prepare variables
infile = args.infile
outfile = args.outfile

# Check if file exists
if not os.path.isfile(infile):
    print("No such file: " + infile)
    exit(1)
    
# Read the file
moddesc_data = json.load(open(infile, 'r'))

# Drop all launchDescriptor elements
moddesc_data.pop('launchDescriptor', None)

# Output the updated file with pretty JSON
open(outfile, "w").write(
        json.dumps(moddesc_data, sort_keys=False, indent=2, separators=(',', ': '))
)

# Exit
exit(0)
