#!/bin/bash
set -e

# The install.sh script is the installation entrypoint for any dev container 'features' in this repository.

# Verify we're on a supported OS
. /etc/os-release
if [ "${ID}" != "debian" ] &&  [ "${ID_LIKE}" != "debian" ]; then
cat << EOF
*********** Unsupported operating system "${ID}" detected ***********
Features support currently requires a Debian/Ubuntu-based image. Update your
image or Dockerfile FROM statement to start with a supported OS. For example:
mcr.microsoft.com/vscode/devcontainers/base:ubuntu
Aborting build...
EOF
    exit 2
fi

# The tooling will parse the devcontainer-features.json + user devcontainer, and write
# any build-time arguments into a feature-set scoped "devcontainer-features.env"
# The author is free to source that file and use it however they would like.
set -a
. ./devcontainer-features.env
set +a


if [ ! -z ${_BUILD_ARG_HOMEBREW_INSTALL} ]; then
    echo "Activating feature 'homebrew-install'"

    # Check if brew command is available
    if [ ! command -v brew &> /dev/null ]; then
        cat << EOF
*********** homebrew not installed ***********
The command `brew` could not be found on the system.
Please make sure to add the homebrew feature before this feature.
Aborting build...
EOF
        exit 2
    fi

    # Taps
    BREW_TAPS=${_BUILD_ARG_HOMEBREW_INSTALL_TAP}

    if [ "$BREW_TAPS" != "" ]; then
        echo "Tapping the following repositories: ${BREW_TAPS}"
        BREW_TAPS_ARRAY=( $BREW_TAPS )

        for i in ${!BREW_TAPS_ARRAY[@]}
        do
            "${BREW_PREFIX}/bin/brew" tap "${BREW_TAPS_ARRAY[i]}"
        done
    fi

    # Install
    BREW_PACKAGES=${_BUILD_ARG_HOMEBREW_INSTALL_PACKAGES}
    if [ "$BREW_PACKAGES" != "" ]; then
        echo "Installing brew packages: ${BREW_PACKAGES}"
        "${BREW_PREFIX}/bin/brew" install "${BREW_PACKAGES}"
    fi
fi
