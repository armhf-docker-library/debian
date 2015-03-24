#!/bin/bash
set -e

IMAGE=$1

# Run updates & tag image
CID=$(docker run -d $IMAGE /bin/bash -c "apt-get update && apt-get -y dist-upgrade")
if [ $? -ne 0 ]; then
  echo Failed starting the container for update!
  exit
fi

echo Waiting for updates to install in $CID
docker wait $CID
if [ $? -ne 0 ]; then
  echo Error during update!
  docker logs $CID
  exit
fi

echo Committing new image
docker commit $CID $IMAGE
