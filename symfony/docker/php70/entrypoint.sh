#!/bin/bash -e

sleep 10;
if [ "$GITHUB_TOKEN" != "" ]; then composer config -g github-oauth.github.com ${GITHUB_TOKEN}; fi
rm -f build.tar
composer install --no-scripts
composer archive --format=tar --dir=. --working-dir=. --file build