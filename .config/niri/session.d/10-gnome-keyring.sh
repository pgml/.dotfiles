#!/bin/sh

# Start gnome-keyring-daemon if not already running
eval "$(gnome-keyring-daemon --daemonize --components=secrets,ssh,gpg,pkcs11)"

# Export the environment variables so other apps can use it
export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID
