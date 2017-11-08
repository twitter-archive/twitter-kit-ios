#!/bin/bash

#  build.sh
#  TwitterCore
#
#  Copyright (c) Twitter. All rights reserved.

set -euo pipefail

# Setup variables
pushd "$(dirname $BASH_SOURCE[0])" >/dev/null
SCRIPT_DIR=$(pwd)
popd >/dev/null
CURRENT_DIR=`pwd`
BUILD_DIR=($CURRENT_DIR/Build)
PROJECT_FILE="$SCRIPT_DIR/TwitterCore.xcodeproj"

# Build and test Twitter Core
xcodebuild clean build test -project $PROJECT_FILE -scheme TwitterCore SYMROOT=$BUILD_DIR OBJROOT=$BUILD_DIR -destination "platform=iOS Simulator,name=iPhone 7" | xcpretty --color
