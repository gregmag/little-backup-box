#!/usr/bin/env bash

# Author: Dmitri Popov, dmpop@linux.com

#######################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################

CONFIG_DIR=$(dirname "$0")
CONFIG="${CONFIG_DIR}/config.cfg"
source "$CONFIG"

# Wait for a USB storage device (e.g., a USB flash drive)
STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
while [ -z "${STORAGE}" ]; do
  sleep 1
  STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
done

sudo mkfs.exfat -n HBSYL /dev/sdb1

# When the USB storage device is detected, mount it
sudo mount /dev/"$STORAGE_DEV" "$STORAGE_MOUNT_POINT"



# Reload minidlna

sudo minidlnad -R
sudo service minidlna restart


# Wait for camera
DEVICE=$(gphoto2 --auto-detect | grep usb | cut -b 36-42 | sed 's/,/\//')
while [ -z "${DEVICE}" ]; do
    sleep 1
    DEVICE=$(gphoto2 --auto-detect | grep usb | cut -b 36-42 | sed 's/,/\//')
done


# Obtain camera model
# Create the target directory with the camera model as its name
CAMERA=$(gphoto2 --summary | grep "Model" | cut -d: -f2 | tr -d '[:space:]')
STORAGE_MOUNT_POINT="$BAK_DIR/Vol_Electro"
sudo mkdir -p "$STORAGE_MOUNT_POINT"

# Switch to STORAGE_MOUNT_POINT and transfer files from the camera
cd "$STORAGE_MOUNT_POINT"
gphoto2 --get-all-files --skip-existing


ls /media/storage/vol_electro | grep -v '\.MP4$' | xargs rm

LIST_FILE="$(mktemp)"
printf "file '$PWD/%s'\n" *.MP4 > $LIST_FILE
ffmpeg -f concat -safe 0 -i $LIST_FILE -c copy MonVolElectrique.MP4
rm $LIST_FILE

sleep 5
sudo umount /media/storage
sleep 2
sudo umount /media/greg/HBSYL
sleep 2
sudo eject /dev/sdb



# Power off
if [ $POWER_OFF = true ]; then
    poweroff
fi


