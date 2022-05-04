#! /usr/bin/env bash

if [ -z "$1" ] 
then
    echo "No image given, cannot deploy update." >&2
    echo "Usage: ./$(basename $0) example.azurecr.io/image:version"
    exit 1
fi

if [ -z "$BOT_TOKEN" ]
then
    echo "Missing \$BOT_TOKEN environment variable, bot would fail to start." >&2
    exit 1
fi

IMAGE="$1"
CONTAINER_NAME="dvc-discord-bot"
DEPLOY_LOCATION='/var/www/discord-dynamic-voice-channels'
VOLUME_LOCATION='/var/www/discord-dynamic-voice-channels/volumes/data'
# This folder location must match the location of the bot's data folder in the Docker container
DATA_FOLDER_LOCATION='/app/data'

if [ ! -d "$VOLUME_LOCATION" ]
then
    mkdir -p "$VOLUME_LOCATION" || exit 1
fi

cd "$DEPLOY_LOCATION"

# Update the docker image
docker pull "$IMAGE"

# Stop and remove the container if it already exists
if [ $(docker ps -q -f name="$CONTAINER_NAME") ]
then
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

# Start the container
docker run \
    --restart "unless-stopped" \
    --name "$CONTAINER_NAME" \
    --volume "$VOLUME_LOCATION:/app/data" \
    -e "BOT_TOKEN=$BOT_TOKEN" \
    -itd \
    "$IMAGE"
