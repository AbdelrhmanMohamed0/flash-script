#!/bin/bash

#!/bin/bash
###########################################################################
# Script Name : Auto-flash.sh
# Author      : Abdelrhman Mohamed Ellawendi
# Email       : eng.abdelrhmanmohamed95@gmail.com
# Created on  : 2025-04-29
# Description : Script to automatically flash a Raspberry Pi  image (.wic)
#               onto a selected device. Supports direct .wic or .wic.bz2 extraction.
#
# Usage       : ./Auto-flash.sh
#
# Notes       : Run as a user with sudo privileges.
#
# Variables   :
#   BASE_PATH         : Change this to point to your build directory base
#   IMAGE_DIRECTORY   : Points to deploy/images/raspberrypi4-64
#
# Requirements:
#   - bash
#   - sudo access
#   - tools: lsblk, dd, bunzip2
#
###########################################################################


# === Configuration: Change this only ===
BASE_PATH="/media/abdelrhman/linux/build_rspi/tmp"
# =======================================

IMAGE_FILE_TYPE="wic"
IMAGE_DIRECTORY="${BASE_PATH}/deploy/images/raspberrypi4-64"

# Check if .rootfs.wic exists directly
IMAGE_TO_FLASH=$(ls "${IMAGE_DIRECTORY}" | grep .rootfs.wic$ | head -n 1)

if [ -n "$IMAGE_TO_FLASH" ]; then
    echo ".wic image found, will flash directly."
    EXTRACTED_IMAGE="${IMAGE_DIRECTORY}/${IMAGE_TO_FLASH}"
else
    echo ".wic not found, looking for .wic.bz2 to extract..."
    IMAGE_TO_FLASH=$(ls "${IMAGE_DIRECTORY}" | grep .rootfs.wic.bz2$ | head -n 1)

    if [ -z "$IMAGE_TO_FLASH" ]; then
        echo "No .wic or .wic.bz2 image found! Exiting."
        exit 1
    fi

    EXTRACTED_IMAGE="${IMAGE_DIRECTORY}/$(basename "${IMAGE_TO_FLASH}" .bz2)"

    if [ -f "$EXTRACTED_IMAGE" ]; then
        echo "The extracted image already exists. Skipping unzip step."
    else
        echo "Unzipping the image file using a temp copy..."
        TEMP_COPY="${BASE_PATH}/temp_image_to_flash.bz2"
        cp "${IMAGE_DIRECTORY}/${IMAGE_TO_FLASH}" "$TEMP_COPY"
        bunzip2 "$TEMP_COPY"
        TEMP_EXTRACTED_IMAGE="${BASE_PATH}/temp_image_to_flash"
        mv "$TEMP_EXTRACTED_IMAGE" "$EXTRACTED_IMAGE"
    fi
fi

# Show disk layout
echo "Here are the connected devices and partitions:"
lsblk
echo ""

# Select device
echo "Please select the device to flash:"
select DEVICE in /dev/sdb /dev/sdc /dev/sdd /dev/sde
do
    if [ -n "$DEVICE" ]; then
        echo "You selected ${DEVICE}"
        break
    else
        echo "Invalid choice. Please choose a valid device."
    fi
done

# Select action
select use_option in erase flash
do
    case ${use_option} in
        erase)
            echo "Erasing ${DEVICE}..."
            sudo umount ${DEVICE}1 2>/dev/null
            sudo umount ${DEVICE}2 2>/dev/null
            time sudo dd if=/dev/zero of=${DEVICE} bs=10000 count=1000
            break
            ;;
        flash)
            echo "Flashing ${DEVICE}..."
            time sudo dd if=${EXTRACTED_IMAGE} of=${DEVICE} bs=1M iflag=fullblock
            break
            ;;
        *)
            echo "Invalid input! Press 1 to erase or 2 to flash"
            ;;
    esac
done

# Final sync
echo "sync now"
sync
echo "All success!"

