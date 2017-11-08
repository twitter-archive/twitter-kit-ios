#!/bin/bash

#  build.sh
#  TwitterKit
#
#  Copyright (c) Twitter. All rights reserved.

set -euo pipefail

# Setup variables
CURRENT_DIR=`pwd`

pushd "$(dirname $BASH_SOURCE[0])" >/dev/null
TWITTERKIT_DIR=$(pwd)
popd >/dev/null
TWITTERKIT_PROJECT_FILE="$TWITTERKIT_DIR/TwitterKit.xcodeproj"

BUILD_DIR=($TWITTERKIT_DIR/Build)

TWITTERCORE_DIR=$TWITTERKIT_DIR/../TwitterCore
TWITTERCORE_PROJECT_FILE="$TWITTERCORE_DIR/TwitterCore.xcodeproj"


# Build Twitter Core
xcodebuild clean build -project $TWITTERCORE_PROJECT_FILE -scheme TwitterCore SYMROOT=$BUILD_DIR OBJROOT=$BUILD_DIR -destination "platform=iOS Simulator,name=iPhone 7" | xcpretty --color

# Copy locally
cp -r $BUILD_DIR/Debug-iphonesimulator/TwitterCore.framework $BUILD_DIR

# Build and test TwitterKit
xcodebuild clean build test -project $TWITTERKIT_PROJECT_FILE -scheme TwitterKit SYMROOT=$BUILD_DIR OBJROOT=$BUILD_DIR -destination "platform=iOS Simulator,name=iPhone 7" | xcpretty --color
