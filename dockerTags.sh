#!/bin/bash
#
# SOURCE: https://stackoverflow.com/questions/28320134/how-to-list-all-tags-for-a-docker-image-on-a-remote-registry
#
# Fri Dec 22 14:28:36 PST 2017
#

if [ $# -lt 1 ]
then
cat << HELP

dockertags  --  list all tags for a Docker image on a remote registry.

EXAMPLE:
 - list all tags for ubuntu:
   ${0} ubuntu

- list all php tags containing apache:
   ${0}  php apache

HELP
fi

image="$1"
tags=`wget -q https://registry.hub.docker.com/v1/repositories/${image}/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'`

if [ -n "$2" ]
 then
  tags=` echo "${tags}" | grep "$2" `
fi

echo "${tags}"
