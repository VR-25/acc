#!/bin/bash

get_prop() { sed -n "s/^$1=//p" module.prop; }

zip -r9u "$(get_prop id)-$(get_prop version).zip" * -x zip.sh
