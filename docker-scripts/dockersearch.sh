#!/bin/bash
#
# SOURCE:  https://stackoverflow.com/questions/28320134/how-can-i-list-all-tags-for-a-docker-image-on-a-remote-registry
#
# curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/python/tags?page_size=1024'|jq '."results"[]["name"]'
# curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/ubuntu/tags?page_size=1024'|jq '."results"[]["name"]'
#

# Fri Dec 22 14:28:36 PST 2017
#

# if [ $# -lt 1 ]
# then
# cat << HELP

# dockertags  --  list all tags for a Docker image on a remote registry.

# EXAMPLE:
#  - list all tags for ubuntu:
#    ${0} ubuntu

# - list all php tags containing apache:
#    ${0}  php apache

# HELP
# fi

image="$1"

echo "${image}"

# v1 API is now obsolete Wed 2022Dec28 13:55:01 PST
#tags=`wget -q https://registry.hub.docker.com/v1/repositories/${image}/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'`

# v2 API works
echo "curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/"${image}"/tags?page_size=1024' | jq '.\"results\"[][\"name\"]'"

#+ These work directly in the CLI, but do not work from the script.
# curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/ubuntu/tags?page_size=1024'|jq '."results"[]["name"]'
# curl -L -s 'https://registry-1.docker.io/v2/repositories/library/ubuntu/tags?page_size=1024'|jq '."results"[]["name"]'

#- These do not work from the script
#- curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/\"${image}\"/tags?page_size=1024'  | jq '."results"[]["name"]'
#- curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/"${image}"/tags?page_size=1024' | jq --color-output
