#!/bin/bash

#  build.sh
#  Fabric
#
#  Copyright (c) 2016 Twitter. All rights reserved.

set -euo pipefail # pipefail to bubble errors from build_framework.sh

# cd to directory of script
cd "$( dirname "${BASH_SOURCE[0]}" )"
source ../Scripts/common.sh

FAB_BUILD_OUTPUT_DIR="${TWITTER_CORE_DIR}"/Artifacts
FAB_CONFIGURATION="${2:-Release}"
FAB_LOG_LOCATION="${3:-$FAB_BUILD_OUTPUT_DIR/Logs}"

mkdir -p "${FAB_BUILD_OUTPUT_DIR}"
mkdir -p "${FAB_LOG_LOCATION}"

function build_for_platform {
    FAB_PLATFORM="${1}"
    log "Building Twitter Core for ${FAB_PLATFORM}"

    rm -rf "${FAB_BUILD_OUTPUT_DIR}/Build" # delete any derived data build products that may be left over
    "${SCRIPTS_DIR}"/build_framework.sh                                          \
        TwitterCore                                                       \
        "${FAB_PLATFORM}"                                                 \
        "$FAB_BUILD_OUTPUT_DIR"                                           \
        "$FAB_CONFIGURATION"                                              \
        "$TWITTER_CORE_DIR/TwitterCore.xcodeproj"                \
        | tee "${FAB_LOG_LOCATION}/twittercore-${FAB_PLATFORM}-build.log" \
        | xcpretty
}

function zip_framework {
    FAB_PLATFORM="${1}"

    log "Zipping up framework for ${FAB_PLATFORM}"
	"${SCRIPTS_DIR}"/zip_framework.sh TwitterCore "${FAB_BUILD_OUTPUT_DIR}" "${FAB_CONFIGURATION}" "${FAB_PLATFORM}"
}

build_for_platform "phone"
build_for_platform "tv"

# zip up the built frameworks
log "Archiving framework bundles"
zip_framework "phone"
zip_framework "tv"

log "Build Twitter Core Kit CocoaPod"
 "${SCRIPTS_DIR}"/create_cocoapod_archive.sh            \
    TwitterCore                                  \
    "${TWITTER_CORE_DIR}"/cocoapod_readme.md \
    "$FAB_BUILD_OUTPUT_DIR"                      \
    "$FAB_CONFIGURATION"                         \
    > "${FAB_LOG_LOCATION}/twittercore-create-cocoapod-archive.log"
