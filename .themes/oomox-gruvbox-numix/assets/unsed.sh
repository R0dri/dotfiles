#!/bin/sh
sed -i \
         -e 's/rgb(0%,0%,0%)/#32302f/g' \
         -e 's/rgb(100%,100%,100%)/#fbf1c7/g' \
    -e 's/rgb(50%,0%,0%)/#3c3836/g' \
     -e 's/rgb(0%,50%,0%)/#bdae93/g' \
 -e 's/rgb(0%,50.196078%,0%)/#bdae93/g' \
     -e 's/rgb(50%,0%,50%)/#3c3836/g' \
 -e 's/rgb(50.196078%,0%,50.196078%)/#3c3836/g' \
     -e 's/rgb(0%,0%,50%)/#d5c4a1/g' \
	$@