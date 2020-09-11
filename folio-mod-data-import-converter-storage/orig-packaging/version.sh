#!/bin/bash
grep -m 1 "<version>" pom.xml | grep -oE "([0-9]+\.){2}[0-9]+"
