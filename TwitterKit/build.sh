#!/bin/bash

#  build.sh
#  Fabric
#
#  Copyright (c) 2016 Twitter. All rights reserved.

set -euox pipefail # pipefail to bubble errors from build_framework.sh

# cd to directory of script
cd "$( dirname "${BASH_SOURCE[0]}" )"
source ../Scripts/common.sh

FAB_BUILD_OUTPUT_DIR="${SDK_ROOT}/TwitterKit/Artifacts"
FAB_CONFIGURATION="${2:-Release}"
FAB_LOG_LOCATION="${3:-$FAB_BUILD_OUTPUT_DIR/Logs}"

mkdir -p "${FAB_BUILD_OUTPUT_DIR}"
mkdir -p "${FAB_LOG_LOCATION}"


log "Build Twitter Kit for phone"
rm -rf "${FAB_BUILD_OUTPUT_DIR}/Build" # delete any derived data build products that may be left over
    "${SCRIPTS_DIR}"/build_framework.sh        \
    TwitterKit                      \
    phone                           \
    "$FAB_BUILD_OUTPUT_DIR"         \
    "$FAB_CONFIGURATION"            \
    "$TWITTER_KIT_DIR/TwitterKit.xcodeproj" \
    | tee "${FAB_LOG_LOCATION}/twitterkit-phone-build.log" \
    | xcpretty


log "Archive the framework bundle."
sh "$SCRIPTS_DIR/zip_framework.sh" TwitterKit "${FAB_BUILD_OUTPUT_DIR}" "${FAB_CONFIGURATION}" phone


log "Build Twitter Kit CocoaPod"
sh "$SCRIPTS_DIR/create_cocoapod_archive.sh"           \
    TwitterKit                                  \
    "$TWITTER_KIT_DIR/README.md" \
    "$FAB_BUILD_OUTPUT_DIR"                     \
    "$FAB_CONFIGURATION"                        \
    > "${FAB_LOG_LOCATION}/twitterkit-create-cocoapod-archive.log"
