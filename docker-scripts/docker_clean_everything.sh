#!/bin/sh

function cleanup (){
  echo;echo "Delete all existing containers..."
  docker rm  $(docker ps -a -q)
  echo;echo "Delete all images..."
  docker rmi -f $(docker images -q)
}

cleanup
echo;echo
