 #!/bin/bash

# Configured sink and source to be used with Jack
SINK='alsa_output.usb-BEHRINGER_UMC1820_605B4717-00.multichannel-output'
SOURCE='alsa_input.usb-BEHRINGER_UMC1820_605B4717-00.multichannel-input module-alsa-card.c '

# Suspend just the devices we want to use with Jack
pacmd suspend-sink $SINK true
pacmd suspend-sink $SOURCE true
