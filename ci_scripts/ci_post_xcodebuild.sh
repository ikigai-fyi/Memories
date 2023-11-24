#!/bin/sh

set -e

# This is necessary in order to have sentry-cli
# install locally into the current directory
export INSTALL_DIR=$PWD

# For some reason Sentry CLI install is broken as of 24/11/2023
exit 0

if [[ $(command -v sentry-cli) == "" ]]; then
    echo "Installing Sentry CLI"
    brew install getsentry/tools/sentry-cli
fi

echo "Uploading dSYM to Sentry"

sentry-cli --auth-token $SENTRY_AUTH_TOKEN \
    upload-dif --org 'ikigai-y1' \
    --project 'memories' \
    $CI_ARCHIVE_PATH
