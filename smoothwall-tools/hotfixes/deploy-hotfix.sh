#!/bin/bash
#
# This shell script is a templated example on how to use systemrestore to
# automatically generate a restore point prior to installing a hotfix
# (software which is outside of the standard update mechanism).
#
# This script should be copied and tarred with the corresponding deployment
# artefacts, and serves as a guide only.
#
# Suggestions for values which should be changed, are written <like this>.

set -e

# Create a system restore point.
echo "Creating system restore point..."
/usr/bin/smoothwall/systemrestore create <before-hotfix-NNN>

# Install the hotfix/copy files as appropriate.
echo "Installing hotfix..."
#
# <cp files>
# or:
# <dpkg -i *.deb>

# Perform any post-hotfix actions such as restarting any services.

echo "Done..."
