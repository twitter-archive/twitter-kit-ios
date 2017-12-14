#!/bin/bash

#  build.sh
#  FabricSampleApp
#
#  Copyright (c) Twitter. All rights reserved.

set -eu

echo "Picking device."
DEVICE=$( instruments -s | grep -m 1 'iPhone.*\(9\.3\)' | cut -d ' ' -f 2 )
DESTINATION="platform=iOS Simulator,name=iPhone $DEVICE,OS=9.3"
[[ -z "$DEVICE" ]] && { echo "Valid iPhone not found. Aborting."; exit 1; }

echo "Building app with destination: $DESTINATION"
# Build and run all the tests in the Fabric Sample App
xcodebuild clean build test -workspace FabricSampleApp.xcworkspace -scheme FabricSampleApp SYMROOT=`pwd`/Build OBJROOT=`pwd`/Build -destination "${DESTINATION}" | xcpretty --color --report junit --output Build/junit.xml && exit ${PIPESTATUS[0]}
