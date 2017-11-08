#!/bin/bash
#  upload.sh

set -eu

# cd to directory of script
cd "$( dirname "${BASH_SOURCE[0]}" )"
source ../Scripts/common.sh

log "Uploading Twitter Core"

STAGING=${1:-"-staging"} # use "-staging" if nothing passed in
STAGING=${STAGING/"release"} # use "" if "release" passed in

# Get the version
VERSION=$(framework_version ${TWITTER_CORE_FRAMEWORK})

FILE="${TWITTER_CORE_DIR}/Artifacts/CocoaPods/TwitterCore.zip"
KEY="twitterkit/ios/${VERSION}${STAGING}/TwitterCore.zip"

# Upload
$SCRIPTS_DIR/upload_to_blobstore.sh "${KEY}" "${FILE}"
