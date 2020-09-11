#!/bin/bash
grep -m 1 "appVersion=" service/gradle.properties | grep -oE "([0-9]+\.){2}[0-9]+"
