#!/usr/bin/env bash

# Author: G. Magnin

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
SUDOPASS=lsgt1735
POWER_OFF=false
BAK_DIR="/media/storage"
STORAGE_MOUNT_POINT="/media/storage"
STORAGE_DISK="sda"
STORAGE_DEV="sda1"

echo "Veuillez patienter ..."

sleep 1
echo "$SUDOPASS" | sudo -S umount /media/storage
sleep 1
echo "$SUDOPASS" | sudo -S umount /media/HBSYL
sleep 1
echo "$SUDOPASS" | sudo -S fusermount -u /media/gopro
sleep 1
gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio mount -u "$2)}'
clear

echo "Bonjour cher pilote"
echo ""
echo "Les données du stick seront écrasées, les vidéos seront copiées et la caméra effacée"
echo ""

sleep 5
#read -p "Êtes-vous sûr de vouloir continuer ? (tapez O pour oui ou n'importe quelle touche suvie de ENTER pour quitter) "

#if [[ $REPLY =~ ^[0Oo]$ ]]
#then

echo ""
echo "Veuillez insérer le stick USB du côté gauche"


# Wait for a USB storage device (e.g., a USB flash drive)
STORAGE=$(ls /dev/* | grep "$STORAGE_DISK" | cut -d"/" -f3)
while [ -z "${STORAGE}" ]; do
  sleep 1
  STORAGE=$(ls /dev/* | grep "$STORAGE_DISK" | cut -d"/" -f3)
done

echo "Stick détecté"
echo ""

sleep 2
echo "$SUDOPASS" | sudo -S umount /dev/sda1

sleep 3
echo 'type=0B' | sudo sfdisk /dev/sda
clear

sleep 3
echo "$SUDOPASS" | sudo -S mkfs.fat -n HBSYL /dev/sda1
#echo "$SUDOPASS" | sudo -S mkfs.ntfs -Q -L HBSYL /dev/sda1

sleep 3
# When the USB storage device is detected, mount it
#mount /dev/"$STORAGE_DEV" "$STORAGE_MOUNT_POINT"
mount /dev/sda1
clear

echo ""
echo "En attente de la caméra"
echo "Vérifiez qu'elle est connectée et allumée"

# Wait for camera
DEVICE=$(gphoto2 --auto-detect | grep usb | cut -b 36-42 | sed 's/,/\//')
while [ -z "${DEVICE}" ]; do
    sleep 1
    DEVICE=$(gphoto2 --auto-detect | grep usb | cut -b 36-42 | sed 's/,/\//')
done

echo " "
echo "Caméra détectée"

# Obtain camera model
# Create the target directory with the camera model as its name
CAMERA=$(gphoto2 --summary | grep "Model" | cut -d: -f2 | tr -d '[:space:]')
STORAGE_MOUNT_POINT="$BAK_DIR/Vol_Electro"
#STORAGE_MOUNT_POINT="$BAK_DIR"
echo "$SUDOPASS" | sudo -S mkdir -p "$STORAGE_MOUNT_POINT"
#echo "$SUDOPASS" | sudo -S chmod a+rwx "$STORAGE_MOUNT_POINT"
#echo "$SUDOPASS" | sudo -S chown pi:pi "$STORAGE_MOUNT_POINT"
clear


#jmtpfs -o allow_other -o nonempty /media/gopro
gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio mount "$2)}'

#echo "$SUDOPASS" | sudo -S cp -vr "/media/gopro/GoPro MTP Client Disk Volume/DCIM/100GOPRO"/*.MP4 /media/storage/
gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio list -u "$2"GoPro\ MTP\ Client\ Disk\ Volume/DCIM/100GOPRO/")}' | grep '.MP4' | sort -u | xargs -i gio copy -p {} /media/storage/Vol_Electro

sleep 5

gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio mount -u "$2)}'
echo "$SUDOPASS" | sudo -S fusermount -u /media/gopro
sleep 5

echo 'y' | mtp-format

sleep 5

# Switch to STORAGE_MOUNT_POINT and transfer files from the camera
#cd "$STORAGE_MOUNT_POINT"
#echo "$SUDOPASS" | sudo -S gphoto2 --get-all-files --skip-existing --delete-all-files -f /store_00000004/DCIM --recurse
#echo "$SUDOPASS" | sudo -S gphoto2 --get-all-files --skip-existing
#echo "$SUDOPASS" | sudo -S gphoto2 --delete-all-files -f /store_00000004/DCIM --recurse

#echo "$SUDOPASS" | sudo -S ls /media/storage
#echo "$SUDOPASS" | ls /media/storage/Vol_Electro | grep -v '\.MP4$' | sudo -S xargs rm

#LIST_FILE="$(mktemp)"
#printf "file '$PWD/%s'\n" *.MP4 > $LIST_FILE
#ffmpeg -f concat -safe 0 -i $LIST_FILE -c copy MonVolElectrique.MP4
#rm $LIST_FILE

sleep 1
echo "$SUDOPASS" | sudo -S umount /media/storage
sleep 1
echo "$SUDOPASS" | sudo -S umount /media/pi/HBSYL
sleep 1
echo "$SUDOPASS" | sudo -S umount /media/HBSYL
sleep 1
echo "$SUDOPASS" | sudo -S fusermount -u /media/gopro
sleep 1
gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio mount -u "$2)}'
sleep 2
echo "$SUDOPASS" | sudo -S udisksctl power-off -b /dev/sda

clear

#fi

echo "Terminé !"
echo "Vous pouvez débrancher la caméra et le stick USB"
echo " "

sleep 30

#read -p "Pressez une touche pour fermer cette fenêtre ..."

# Power off
if [ $POWER_OFF = true ]; then
    poweroff
fi


