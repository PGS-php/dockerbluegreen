#!/usr/bin/env bash

TASK_NAME=$1;
ENV_START=${2:-dev};
source ./variables.sh
export USERID=$(id -u)
echo "User ID: $USERID"
echo "IMAGE VERSION: $APP_NAME:$APP_VERSION"
declare -i BUILD_STATUS=0

function buildImages {
    NAME=$1
    VERSION=$2
    USERID=${3:-1000}

    docker build -t "${NAME}:${VERSION}-php56" --build-arg USERID="$USERID" docker/php56
    docker build -t "${NAME}:${VERSION}-nginx" docker/nginx
}

function runBuild {
    export IMAGE_VERSION=$1
    echo "  IMAGE_VERSION: ${IMAGE_VERSION}" >> $configYml
    BUILD_OUTPUT=$(docker-compose up php)
    docker-compose kill > /dev/null 2>&1
    docker-compose rm -f -v > /dev/null 2>&1

    echo -e "$BUILD_OUTPUT";
    if echo "$BUILD_OUTPUT" | grep -q "exited with code 0"; then
        BUILD_STATUS=0;
    else
        BUILD_STATUS=1;
    fi
    source ./export.sh
}

function runInBackground {
    export IMAGE_VERSION=$1
    echo "  IMAGE_VERSION: ${IMAGE_VERSION}" >> $configYml
    docker-compose -f docker-compose.yml -f docker-compose.local.yml kill > /dev/null 2>&1
    docker-compose -f docker-compose.yml -f docker-compose.local.yml rm -f -v > /dev/null 2>&1
    docker-compose -f docker-compose.yml -f docker-compose.local.yml up -d mysql nginx php
    docker-compose -f docker-compose.yml -f docker-compose.local.yml run --entrypoint /bin/bash php
    docker-compose -f docker-compose.yml -f docker-compose.local.yml kill > /dev/null 2>&1
    docker-compose -f docker-compose.yml -f docker-compose.local.yml rm -f -v > /dev/null 2>&1
}

function projectInstall {
    docker-compose -f docker-compose.yml -f docker-compose.local.yml run --entrypoint "composer install --no-scripts" php
}

if [[ $TASK_NAME == '' ]]; then
    echo -e "Available commands:";
    echo -e "'build-images' - building docker images";
    echo -e "'run' - is running dev env and attaching tty";
    echo -e "'build' - is running build ant tasks based on php 56";
fi

case $TASK_NAME in
    'build-images')
        buildImages "${APP_NAME}" "${APP_VERSION}" "${USERID}"
        ;;
    'install')
        projectInstall "${APP_NAME}" "${APP_VERSION}"
        ;;
    'build')
        runBuild "${APP_NAME}:${APP_VERSION}-php56"
        ;;
    'run')
        runInBackground "${APP_NAME}:${APP_VERSION}-php56"
        ;;
esac

echo -e "Script finished with exit code: ${BUILD_STATUS}";
