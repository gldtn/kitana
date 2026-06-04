#!/bin/bash

# system.sh: Core system and hardware package stages.

echo "Installing system packages..."

source_script "system/base.sh"
source_script "system/audio.sh"
source_script "system/gpu.sh"
