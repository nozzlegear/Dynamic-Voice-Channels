#! /usr/bin/env bash

# Exit when any command fails
set -e

LOG_FILE="/var/log/discord-dynamic-voice-channels.log"

printErr () {
    RED='\033[0;31m'
    NORMAL='\033[0m'

    echo -e "${RED}$@${NORMAL}" >&2
}

log () {
    timestamp=$(date -u "+%F T%TZ")
    echo "[$timestamp]: $@" >> "$LOG_FILE"
    # Also echo back to the console
    echo "$@"
}

IMAGE="$1"
CONTAINER_NAME="dvc-discord-bot"
DEPLOY_LOCATION='/var/www/discord-dynamic-voice-channels'
ENV_FILE_LOCATION='/var/www/discord-dynamic-voice-channels/.env'
VOLUME_LOCATION='/var/www/discord-dynamic-voice-channels/volumes/data'
# This folder location must match the location of the bot's data folder in the Docker container
DATA_FOLDER_LOCATION='/app/data'

if [ -z "$IMAGE" ] 
then
    printErr "No image given, cannot deploy update."
    echo "Usage: ./$(basename $0) example.azurecr.io/image:version"
    exit 1
fi

if [ ! -d "$VOLUME_LOCATION" ]
then
    mkdir -p "$VOLUME_LOCATION" || exit 1
fi

if [ ! -f "$ENV_FILE_LOCATION" ]
then
    printErr "Failed to locate env file at $ENV_FILE_LOCATION, bot would fail to start."
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
        printErr "'podman', 'docker ps' and 'sudo docker ps' commands failed to return a successful exit code. Are Podman or Docker configured properly? Do 'podman ps', 'docker ps' or 'sudo docker ps' work?"
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

cd "$DEPLOY_LOCATION"

# Update the image
log "Pulling image $IMAGE..."
pod pull "$IMAGE"

# Stop and remove the container if it already exists
EXISTING_CONTAINER_ID=$(pod ps --all -q -f name="$CONTAINER_NAME")

if [ ! -z "$EXISTING_CONTAINER_ID" ]
then
    log "Stopping and removing existing container \"$CONTAINER_NAME\"..."
    pod stop "$EXISTING_CONTAINER_ID"
    pod rm "$EXISTING_CONTAINER_ID"
fi

# Start the container
log "Starting container..."
pod run \
    --restart "unless-stopped" \
    --name "$CONTAINER_NAME" \
    --volume "$VOLUME_LOCATION:/app/data" \
    --env-file "$ENV_FILE_LOCATION" \
    -itd \
    "$IMAGE"

log "Done!"
