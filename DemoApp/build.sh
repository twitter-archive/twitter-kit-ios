#!/usr/bin/env bash

# cd to directory of script
cd "$( dirname "${BASH_SOURCE[0]}" )" || exit

# For xcpretty to properly parse cocoapods output
export LC_ALL=en_US.UTF-8

# Build sample app
xcodebuild -workspace FabricSampleApp.xcworkspace -scheme FabricSampleApp -configuration Release build -sdk iphoneos | xcpretty
