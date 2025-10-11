#!/bin/bash
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# Description:  
# This script lists all tags for a Docker image on Docker Hub.
#
# (!) This endpoint is deprecated and will be removed in a future version of Docker Hub.
#  https://registry.hub.docker.com/v1/repositories/${image}/tags
#
# The Docker Hub API v2 endpoint expects the image name in the format 
# namespace/repository (e.g., library/ubuntu for the official Ubuntu image), 
# not just ubuntu.
#
# This script is provided as-is without any warranty. Use at your own risk.
#
# Usage: ./dockerTags.sh <image_name> [<search_term>]
# Examples:
#   ./dockerTags.sh ubuntu
#   ./dockerTags.sh php apache
#   ./dockerTags.sh php apache | grep RC1
#   ./dockerTags.sh php apache | grep 8.3 | sort -u
#   ./dockerTags.sh php apache | grep 8.3 | sort -u | tail -n 3
#   ./dockerTags.sh php apache | grep RC1 | sort -u | tail -n 3 | xargs -I {} docker pull php:apache
#
# SOURCE: https://stackoverflow.com/questions/28320134/how-to-list-all-tags-for-a-docker-image-on-a-remote-registry
#
# Version: 1.0
# License: MIT
# Maintainer: devesplab
#
# Sat 2025May24 16:15:21 PDT
# Fri Dec 22 14:28:36 PST 2017
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

image="$1" # The first argument is the image name
search_term="$2" # The second argument is the search term (optional)

#
# Add 'library/' if no namespace is provided
# This is necessary for official images on Docker Hub such as 'ubuntu', 'nginx', etc.
#
add_namespace() {
local img="$1"
  if [[ "$img" != */* ]]; then
    img="library/$img"
  fi
  echo "$img"
}

#
# Usage message if no arguments are provided
# Check if the script is run with at least one argument
#
check_usage() {
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
}

#
# Fetch tags from Docker Hub API v2
#
fetch_tags() {
local img="$1"
  curl -s "https://hub.docker.com/v2/repositories/${img}/tags?page_size=100" \
    | grep -o '"name":"[^"]*"' | awk -F: '{print $2}' | tr -d '"'
}

#
# Main function to execute the script logic
#
main() {
   check_usage "$@"

   # Capture the output of add_namespace in a variable
   image=$(add_namespace "$image")

   # Check if the image variable is empty
   if [ ! -z "$image" ]; then
      echo
      echo "Fetching tags for image: ${image}"
      echo
   fi

   # Fetch tags for the specified image
   tags=$(fetch_tags "$image")

   # Check if tags were fetched successfully
   if [ ! -z "$search_term" ]; then
      echo
      echo "Filtering tags for image: ${image} with search term: $search_term"
      echo
      tags=$(echo "${tags}" | grep "$search_term")
      if [ -z "$tags" ]; then
         echo
         echo "No tags found for image: ${image} with search term: $search_term"
         echo
         exit 0
      fi
   fi

   echo "${tags}"
}

#
# Execute the main function with all script arguments#
#
main "$@"