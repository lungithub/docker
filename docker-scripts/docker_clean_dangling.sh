#!/bin/bash
#
# Docker clean up dangling images
#
# 
# Docker prune will ask you what to clean up. Answer y/N.
# 
# -> docker system prune
# WARNING! This will remove:
#   - all stopped containers
#   - all networks not used by at least one container
#   - all dangling images
#   - all dangling build cache
# 
# Are you sure you want to continue? [y/N]
# 
# Echo the response to automate this.
# 
# REFERENCE:
# https://docs.docker.com/config/pruning/
# Updated: Sat 2021Jun19 12:29:04 PDT
# 

echo;echo "Clean dangling images"
docker volume rm $(docker volume ls -qf dangling=true) || true
docker rmi $(docker images --filter "dangling=true" -q --no-trunc) || true

echo;echo "Clean everything, including dangling images"
echo "y" | docker system prune

echo "Done."
echo