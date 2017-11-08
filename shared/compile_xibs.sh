#!/bin/sh

set -e # Do not remove, verification depends on failing on non zero status codes

# compiles the .xib files inside the specified bundle directory into .nibs
# removes the original .xib files
function compile_xibs {
    BUNDLE_DIR="${1}"

    if [[ ${BUNDLE_DIR} == "" ]]; then
    	echo "BUNDLE_DIR required"
    	exit 1
    fi

	# Iterating through .xib files that can be in paths containing spaces
	# http://askubuntu.com/questions/343727/filenames-with-spaces-breaking-for-loop-find-command
	find "${BUNDLE_DIR}" -name *.xib -print0 | while IFS= read -r -d '' XIB_FILE_PATH; do
		XIB_FULL_FILE_NAME=${XIB_FILE_PATH##*/}
		XIB_FILE_NAME=$(basename ${XIB_FULL_FILE_NAME} .xib)
        XIB_DIRECTORY=${XIB_FILE_PATH%$XIB_FULL_FILE_NAME}

        xcrun ibtool "${XIB_FILE_PATH}" --compile "${XIB_DIRECTORY}/${XIB_FILE_NAME}.nib"

        rm "${XIB_FILE_PATH}"
    done
}

compile_xibs "$1"