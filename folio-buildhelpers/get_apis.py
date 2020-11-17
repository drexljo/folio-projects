#!/usr/bin/python3

# Import modules
import argparse
import fnmatch
import json
import os

# Handle parameters
param_parser = argparse.ArgumentParser(description='Search json file for all APIs provided and throw out the service file too.')
param_parser.add_argument("--infile", "-i", action="store", dest="infile", help="File to work on")
param_parser.add_argument("--provides", "-p", action="store_true", dest="provides", help="Only show provides")
param_parser.add_argument("--requires", "-r", action="store_true", dest="requires", help="Only show requirements")
param_parser.add_argument("--show-service", "-s", action="store_true", dest="show_service", help="Add the servicefile name")
args = param_parser.parse_args()

# Prepare variables
infile = args.infile
provides = args.provides
requires = args.requires
show_service = args.show_service

# Handle arguments
if provides == True and requires == True:
    print("'--provides' and '--requires' are mutually exclusive!")
    exit(1)
elif provides == True:
    show_provides = True
    show_requires = False
    omit_title = True
elif requires == True:
    show_provides = False
    show_requires = True
    omit_title = True
else:
    show_provides = True
    show_requires = True
    omit_title = False

# Check if files exist
if not os.path.isfile(infile):
    print("No such file: " + infile)
    exit(1)

if show_service == True:
    if fnmatch.filter(os.listdir(os.path.dirname(infile)), '*.service'):
        servicefile = fnmatch.filter(os.listdir(os.path.dirname(infile)), '*.service')[0]
    else:
        print("Can't find the service file!")
        exit(1)

# Check for the 
# Read the file
moddesc_data = json.load(open(infile, 'r'))

# Print out all provided APIs
if show_provides == True:
    if not omit_title == True:
        print("Provided APIs:")
    for api in moddesc_data['provides']:
        if show_service == True:
            print(api['id'] + " " + servicefile)
        else:
            print(api['id'])

if show_provides == True and show_requires == True:
    print("")
# Print out all required APIs
if show_requires == True:
    if not omit_title == True:
        print("Required APIs:")
    if "requires" in moddesc_data:
        for api in moddesc_data['requires']:
            if show_service == True:
                print(api['id'] + " " + servicefile)
            else:
                print(api['id'])
    else:
        print("<--No requirements-->")

# Exit
exit(0)
