#!/bin/bash

# Get version type (minor, major, patch) from the first argument
version_type=$1

# Ensure that the user is on the main branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ]; then
  echo "You must be on the main branch to create a new version."
  exit 1
fi

# Check if the version type is valid
if [ "$version_type" != "major" ] && [ "$version_type" != "minor" ] && [ "$version_type" != "patch" ]; then
  echo "Invalid version type. Please use 'major', 'minor', or 'patch'."
  exit 1
fi


# Get the git tag of the last release
last_tag=$(git describe --tags --abbrev=0)

# Get the version number of the last release
last_version=$(echo $last_tag | sed 's/v//')

# Increment the version number
if [ "$version_type" == "major" ]; then
  new_version=$(echo $last_version | awk -F. '{$1++; print $1".0.0"}')
elif [ "$version_type" == "minor" ]; then
  new_version=$(echo $last_version | awk -F. '{$2++; print $1"."$2".0"}')
else
  new_version=$(echo $last_version | awk -F. '{$3++; print $1"."$2"."$3}')
fi

# Print the new version number
echo "New tag: $new_version"

# Add a confirmation before creating the new version
read -p "Do you want to create a new \"$version_type\" version? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

# Create a new git tag
git tag -a "v$new_version" -m "Version $new_version"

# Push the new tag to the remote repository
git push origin "v$new_version"

# Print a success message
echo "New version published successfully."
