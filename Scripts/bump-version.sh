#!/usr/bin/env bash

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd)
CONFIG_PATH="$REPO_ROOT/LlamaChat/LlamaChat.xcconfig"

# Check for major/minor/patch argument
if [ "$#" -ne 1 ]; then
    SCRIPT=$(readlink -f "${BASH_SOURCE[0]}")
    BASENAME=$(basename "$SCRIPT")

    echo "Usage: $BASENAME <major | minor | patch>"
    echo ""
    echo "Bumps the incremental build as well as the major/minor/patch version of the marketing version."
    exit 1
fi

# Check for .xcconfig file
if ! test -f "$CONFIG_PATH"; then
  echo ".xcconfig file missing at $CONFIG_PATH"
  exit 1
fi

# Parse current version numbers
CURRENT_PROJECT_VERSION=$(grep "CURRENT_PROJECT_VERSION" "$CONFIG_PATH" | cut -d' ' -f3)
MARKETING_VERSION=$(grep "MARKETING_VERSION" "$CONFIG_PATH" | cut -d' ' -f3)

if [[ -z "$CURRENT_PROJECT_VERSION" || -z "$MARKETING_VERSION" ]]; then
    echo "Error: Unable to parse version numbers from xcconfig file."
    exit 1
fi

# Get semver version components
IFS='.' read -r -a VERSION_COMPONENTS <<< "$MARKETING_VERSION"
if [[ "${#VERSION_COMPONENTS[@]}" -ne 3 || -z "${VERSION_COMPONENTS[0]}" || -z "${VERSION_COMPONENTS[1]}" || -z "${VERSION_COMPONENTS[2]}" ]]; then
    echo "Error: Invalid version number."
    exit 1
fi

# Bump incremental version
NEW_CURRENT_PROJECT_VERSION=$CURRENT_PROJECT_VERSION
((NEW_CURRENT_PROJECT_VERSION++))

# Bump marketing version
case "$1" in
  "major" )
    NEW_MARKETING_VERSION="$((${VERSION_COMPONENTS[0]} + 1)).0.0"
    ;;
  "minor" )
    NEW_MARKETING_VERSION="${VERSION_COMPONENTS[0]}.$((${VERSION_COMPONENTS[1]} + 1)).0"
    ;;
  "patch" )
    NEW_MARKETING_VERSION="${VERSION_COMPONENTS[0]}.${VERSION_COMPONENTS[1]}.$((${VERSION_COMPONENTS[2]} + 1))"
    ;;
  * )
    echo "Error: Invalid component argument '$1' - must be 'major', 'minor' or 'patch'."
    exit 1
    ;;
esac

# Write out
echo "Bumping CURRENT_PROJECT_VERSION: $CURRENT_PROJECT_VERSION -> $NEW_CURRENT_PROJECT_VERSION"
echo "Bumping MARKETING_VERSION: $MARKETING_VERSION -> $NEW_MARKETING_VERSION"

sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT_PROJECT_VERSION/CURRENT_PROJECT_VERSION = $NEW_CURRENT_PROJECT_VERSION/g" $CONFIG_PATH
sed -i '' "s/MARKETING_VERSION = $MARKETING_VERSION/MARKETING_VERSION = $NEW_MARKETING_VERSION/g" $CONFIG_PATH
