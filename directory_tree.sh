#!/bin/sh

#HOWTO: Verzeichnis von dem man ein Inhaltsbaum möchte beim Aufruf des Skripts angeben.

ls -R $1 | grep ':$' | sed -e 's/:$//' -e 's/[^\/]*\//|  /g' -e 's/|  \([^|]\)/`--\1/g'