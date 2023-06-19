#!/bin/bash

src=$( egrep '> Could not copy file' runlog | awk '{ print $6 }' | sed -e "s/'//g" -e 's/\.$//g' )
dst=$( egrep '> Could not copy file' runlog | awk '{ print $8 }' | sed -e "s/'//g" -e 's/\.$//g' )


strace /bin/cp $src $dst > copylog 2>&1
cat copylog

