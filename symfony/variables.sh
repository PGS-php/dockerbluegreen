#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PROJECT_NAME=$(cat $DIR/.project_name)
export PROJECT_WEB_DIR=${PROJECT_WEB_DIR:="web"}
export PROJECT_INDEX_FILE=${PROJECT_INDEX_FILE:="app.php"}
export PROJECT_DEV_INDEX_FILE=${PROJECT_DEV_INDEX_FILE:="app_$ENV_START.php"}
export APP_NAME=$(echo $(cat $DIR/composer.json | grep name | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -dc '[:alnum:]\n' | tr '[:upper:]' '[:lower:]'))
export APP_VERSION=$(echo $(cat $DIR/composer.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[",\r]//g'))
export USERID=$(id -u);


configYml=$DIR/dockerinfo.yml
rm -f $configYml

echo "envVars:" >> $configYml
echo "  PROJECT_NAME: ${PROJECT_NAME}" >> $configYml
echo "  PROJECT_INDEX_FILE: ${PROJECT_INDEX_FILE}" >> $configYml
echo "  PROJECT_WEB_DIR: ${PROJECT_WEB_DIR}" >> $configYml
echo "  PROJECT_DEV_INDEX_FILE: ${PROJECT_DEV_INDEX_FILE}" >> $configYml
echo "  APP_NAME: ${APP_NAME}" >> $configYml
echo "  APP_VERSION: ${APP_VERSION}" >> $configYml