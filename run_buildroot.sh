#!/bin/bash
set -e

OUTPUT_DIR=/buildroot_output
BUILDROOT_DIR=/root/buildroot

DOCKER_RUN="docker run
    --rm
    -ti
    -v $(pwd)/buildroot/data:$BUILDROOT_DIR/data
    -v $(pwd)/buildroot/external:$BUILDROOT_DIR/external
    -v $(pwd)/buildroot/rootfs_overlay:$BUILDROOT_DIR/rootfs_overlay
    -v $(pwd)/buildroot/images:$OUTPUT_DIR/images
    desertemu-buildroot"

eval $DOCKER_RUN $@