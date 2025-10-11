#!/bin/bash
#
# SOURCE: https://gecgithub01.walmart.com/devtools/looper-slave-role/blob/e9f5d48244eeeae4b06e3bc3599af23a61acfbce/files/docker_cleanup.sh
#

# @author Dave Young <Dave.Young@walmartlabs.com>
# Script to remove docker dangling images

set -o nounset

# Directory or mount point to check
directory='/mnt'

# Maximum used space in percentage (always keep 40% free)
disk_max_used_pcent='60'

# Maximum docker image size in bytes
docker_image_max='42949672960' #42949672960 (start at 40GB image size)

# Increment value for image size check in bytes (2GB)
docker_image_inc='2147483648'

# Maximum count for size check (20 count along with max 42949672960 and inc 2147483648 and brings us down to 0GB max size image)
docker_image_count='20'

# Check free space
check_space() {
    disk_used_pcent=$(df --output=pcent $directory | tail -n1 | sed 's/^[[:space:]]*//;s/%//')
    if [ $disk_used_pcent -lt $disk_max_used_pcent ]; then
        echo "Free disk space is above the threshhold"
        exit 0
    fi    
}

# List images above max size, exclude looper images
docker_image_list() {
    docker images --format '{{.ID}} {{.Repository}}' | grep -v 'com\/looper\/' | awk '{print $1}' | xargs docker image inspect --format="{{.Size}} {{.ID}}" \
    | awk -v docker_image_max="$docker_image_max" '{if($1>docker_image_max)print$2}' 2>/dev/null

}

# Check if any images exist
docker_image_check() {
    list=$(docker images | wc -l)
    if [ $list -eq 1 ]; then
        echo "No docker images found"
        exit 1
    fi
}

# Check if directory; do space check
if [ -d $directory ]; then
    check_space
else
    echo "$directory is not valid or does not exist"
    exit 1
fi    

# Check if docker is running
if pgrep -x dockerd >/dev/null; then
    echo "Docker daemon is running"
else
    echo "Docker daemon is not running"
    exit 1
fi

# Check if any images exist
docker_image_check

# Clean dangling images and stopped containers first
if check_space; then
    echo "Prune docker images"
    docker system prune -f 
fi

# If prune doesn't free enough, remove images above docker_image_max
if check_space; then
    docker_image_list | xargs docker rmi 2>/dev/null
fi

# If there still isn't enough free, lower the image size threshhold to remove more images
while [ 0 -lt $docker_image_count ]; do
    check_space; docker_image_check
    docker_image_max=$(($docker_image_max - $docker_image_inc))
    docker_image_list | xargs docker rmi 2>/dev/null 
    let docker_image_count=docker_image_count-1
done
exit 0

