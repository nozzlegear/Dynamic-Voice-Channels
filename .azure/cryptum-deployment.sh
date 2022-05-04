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

# Figure out whether to use podman, docker or sudo docker to start containers
if command -v podman;
then
    USE_PODMAN=1
else 
    USE_PODMAN=0

    # Check if the user can use Docker without sudo
    if docker ps &> /dev/null;
    then
        USE_SUDO_FOR_DOCKER=0
    elif [ $(sudo docker ps &> /dev/null) ]
    then
        USE_SUDO_FOR_DOCKER=1
    else
        echo "'podman', 'docker ps' and 'sudo docker ps' commands failed to return a successful exit code. Are Podman or Docker configured properly? Do 'podman ps', 'docker ps' or 'sudo docker ps' work?" >&2
        exit 1
    fi
fi

pod () {
    if [ $USE_PODMAN -eq 1 ]
    then
        podman $@
    elif [ $USE_SUDO_FOR_DOCKER -eq 1 ]
    then
        sudo docker $@
    else
        docker $@
    fi
}

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

# Update the image
pod pull "$IMAGE"

# Stop and remove the container if it already exists
if [ $(docker ps -q -f name="$CONTAINER_NAME") ]
then
    pod stop "$CONTAINER_NAME"
    pod rm "$CONTAINER_NAME"
fi

# Start the container
pod run \
    --restart "unless-stopped" \
    --name "$CONTAINER_NAME" \
    --volume "$VOLUME_LOCATION:/app/data" \
    -e "BOT_TOKEN=$BOT_TOKEN" \
    -itd \
    "$IMAGE"
