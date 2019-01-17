# PARAMETERS DEFAULTS
DEFAULT_BUILD_CONFIG="Release"
DEFAUILT_BUILD_COMMAND="clean build"
PLATFORM_NAMES=("iOS" "tvOS")
IOS_NAMES_SDKS=("iphonesimulator" "iphoneos")
TVOS_NAMES_SDKS=("appletvsimulator" "appletvos")
PROJECTS_NAMES=("TwitterCore" "TwitterKit")
BUILDS_FOR_TV=(true false) #Same order as PROJECTS_NAMES above. Indicates if tvOS SDKs should be used.

#FILES and FOLDERS
ROOT_FOLDER=$(pwd)
SYMROOT="$ROOT_FOLDER/build"
POD_DIRECTORY_NAME="Pod"
README_FILE_NAMES=("cocoapod_readme.md" "README.md") #Same order as PROJECTS_NAMES above.

#FUNCTIONS
function createOrCleanDirectory () {
    echo "Preparing directory... ('$1')"

    if [ -d "$1" ];
    then
        echo "Cleaning build directory"
        rm -rf $1/*
    else
        echo "Build directory does not exist. Creating it..."
        mkdir -p $1
    fi
}

function copyToOutputDirectory () {
    echo "Copying to output directory... (Output directory: $1)"

    FULL_PATH="$ROOT_FOLDER/$1"
    if [ -d "$FULL_PATH" ];
    then
        if [ -d $2 ];
        then
            cp -f -R $2/* $FULL_PATH
        else
            cp -f -R $2 $FULL_PATH
        fi
    else
        echo "Could not find output directory. Full path: $FULL_PATH"
        return 1
    fi
}

function copyReadMeFile () {
    README_FILE_PATH=`echo $README_FILE_TEMPLATE_PATH | sed "s/PROJECT_DIR/$1"`
    echo "ReadMe file to copy: '$README_FILE_PATH'"

    if [ -f "$README_FILE_PATH" ];
    then 
        cp -f $README_FILE_PATH $2
    else
        echo "Could not find readMe file."
    fi
}

function getPodspecVersion () {
    PODSPEC_FILE=$1
    echo $(grep -hnr -m 1 "s.version" $PODSPEC_FILE | grep -o '".*"' | tr -d '"')
}

# PREPARE BUILD DIRECTORY
echo "Preparing build directory..."
createOrCleanDirectory $SYMROOT

#BUILD TWITTERKIT
#for PROJECT_NAME in "${PROJECTS_NAMES[@]}"; do
for ((i = 0; i < ${#PROJECTS_NAMES[@]}; i++)); do
    PROJECT_NAME=${PROJECTS_NAMES[i]}
    echo "Building $PROJECT_NAME"

    XCODEPROJ_NAME="$ROOT_FOLDER/$PROJECT_NAME/$PROJECT_NAME.xcodeproj"
    SCHEME_NAME=$PROJECT_NAME
    CONFIG=$DEFAULT_BUILD_CONFIG
    POD_VERSION=$(getPodspecVersion "$ROOT_FOLDER/$PROJECT_NAME/$PROJECT_NAME.podspec")

    for PLATFORM in "${PLATFORM_NAMES[@]}"; do
        PROJECT_SYMROOT="$SYMROOT/$PROJECT_NAME"
        if [ "$PLATFORM" == "tvOS" ];
        then
            if [ "${BUILDS_FOR_TV[i]}" = true ];
            then
                PLATFORMS_NAMES_SDKS=("${TVOS_NAMES_SDKS[@]}")
            else
                continue
            fi
        else
                PLATFORMS_NAMES_SDKS=("${IOS_NAMES_SDKS[@]}")
        fi

        echo "Building for platform: $PLATFORM"
        PROJECT_SYMROOT+="/$PLATFORM"
        POD_OUTPUT_DIR="$PROJECT_NAME/$POD_DIRECTORY_NAME/$POD_VERSION/$PLATFORM"
        POD_OUTPUT_DIR_FRAMEWORK="$POD_OUTPUT_DIR/$SCHEME_NAME.framework"
        createOrCleanDirectory "$POD_OUTPUT_DIR_FRAMEWORK"

        #BUILD FRAMEWORKS
        BUILDED_FRAMEWORKS=()
        for SDK in "${PLATFORMS_NAMES_SDKS[@]}"; do
            CONFIG_SYMROOT="$PROJECT_SYMROOT/$CONFIG-$SDK"
            
            if !(xcodebuild -project $XCODEPROJ_NAME -scheme $SCHEME_NAME -sdk $SDK ONLY_ACTIVE_ARCH=NO -configuration $CONFIG SYMROOT=$CONFIG_SYMROOT $DEFAUILT_BUILD_COMMAND); 
            then
                echo "Bulding TwitterKit failed in dir: $CONFIG_SYMROOT"
                exit 1
            fi

            FRAMEWORK_FILE_NAME="$CONFIG_SYMROOT/$CONFIG-$SDK/$SCHEME_NAME.framework/"
            FRAMEWORK_FILE_INNERFOLDER="$FRAMEWORK_FILE_NAME/$SCHEME_NAME"
            BUILDED_FRAMEWORKS+=($FRAMEWORK_FILE_INNERFOLDER)
        done

        #CREATE UNIVERSAL FRAMEWORK FOLDER
        UNIVERSAL_FRAMEWORK_FOLDER="$PROJECT_SYMROOT/Universal/$SCHEME_NAME.framework"
        createOrCleanDirectory $UNIVERSAL_FRAMEWORK_FOLDER

        #COPY CONTENTS TO UNIVERSAL FRAMEWORK
        cp -R "$FRAMEWORK_FILE_NAME"/* $UNIVERSAL_FRAMEWORK_FOLDER

        if !(lipo -create ${BUILDED_FRAMEWORKS[@]} -output "$UNIVERSAL_FRAMEWORK_FOLDER/$SCHEME_NAME");
        then
            echo "Creating universal framework failed for project: "
            exit 1
        fi
        copyToOutputDirectory $POD_OUTPUT_DIR_FRAMEWORK $UNIVERSAL_FRAMEWORK_FOLDER

        README_FILE="$ROOT_FOLDER/$PROJECT_NAME/${README_FILE_NAMES[i]}"
        copyToOutputDirectory "$POD_OUTPUT_DIR" $README_FILE

        #ZIP POD CONTENTS
        ZIP_FILE_NAME="$POD_OUTPUT_DIR/../$PLATFORM.zip"
        echo "Creating zip file: $ZIP_FILE_NAME"

        ditto -c -k --sequesterRsrc --keepParent $POD_OUTPUT_DIR $ZIP_FILE_NAME

        #CLEAN UP
        echo "Cleaning up Pod folder..."
        rm -rf $POD_OUTPUT_DIR
    done
done
