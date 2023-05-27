#!/bin/sh

# Exit on any errors
set -e

if [[ -z "${GIT_REPO}" ]]; then
	echo "Error: No Git repository specified. Please set the "GIT_REPO" environment variable."
	exit 1
fi

if [[ -z "${GIT_TAG}" ]]; then
	echo "Error: No Git tag specified. Please set the "GIT_TAG" environment variable."
	exit 1
fi

if [[ -z "${GIT_CLONE_PATH}" ]]; then
	echo "Error: No Git clone path specified. Please set the "GIT_CLONE_PATH" environment variable."
	exit 1
fi

if [[ -z "${TYPST_FILE}" ]]; then
	echo "Error: No Typst file specified. Please set the "TYPST_FILE" environment variable."
	exit 1
fi

if [[ -z "${TYPST_OUTPUT_PATH}" ]]; then
	echo "Error: No Typst output path specified. Please set the "TYPST_OUTPUT_PATH" environment variable."
	exit 1
fi

# Check if the Git clone path exists
if [[ -d "${GIT_CLONE_PATH}" ]]; then
	echo "A folder already exists at the Git clone path. Skipping clone."
	cd ${GIT_CLONE_PATH}

	echo "Pulling latest changes..."
	git pull
else
	echo "Cloning ${GIT_REPO} to ${GIT_CLONE_PATH}..."
	git clone ${GIT_REPO} ${GIT_CLONE_PATH}
	cd ${GIT_CLONE_PATH}
fi

echo "Checking out ${GIT_TAG}..."
git checkout ${GIT_TAG}

# Get full Typst file path
TYPST_FILE_FULL_PATH="${GIT_CLONE_PATH}/${TYPST_FILE}"

# Build the PDF
echo "Building ${TYPST_FILE_FULL_PATH} to ${TYPST_OUTPUT_PATH}..."

# Typst does not fail on error, so we need to check the output
# This captures stdout and stderr

TYPST_COMMAND="typst compile ${TYPST_FILE_FULL_PATH} ${TYPST_OUTPUT_PATH}"

TYPST_TMP=$(mktemp)
TYPST_OUT=$($TYPST_COMMAND 2> "$TYPST_TMP")
TYPST_ERR=$(cat "$TYPST_TMP")
rm "$TYPST_TMP"

# Check for content in stderr or stdout
if [ ! -z "$TYPST_OUT" ] || [ ! -z "$TYPST_ERR" ]; then
	echo "Error: Typst may have encountered an error while compiling the Typst file."
	echo
	echo "Typst Output:"
	echo $TYPST_OUT
	echo
	echo "Typst Error:"
	echo $TYPST_ERR
	exit 1
fi

echo "Done!"
