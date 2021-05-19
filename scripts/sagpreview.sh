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
gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio mount -u "$2)}'
clear

echo "Bonjour cher pilote"
echo ""
echo "Vous allez pouvoir prévisualiser une partie de la vidéo ici"
echo ""
sleep 5

#read -p "Êtes-vous sûr de vouloir continuer ? (tapez O pour oui ou n'importe quelle touche suvie de ENTER pour quitter) "

#if [[ $REPLY =~ ^[0Oo]$ ]]
#then

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

#jmtpfs -o allow_other -o nonempty /media/gopro
gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio mount "$2)}'

#echo "$SUDOPASS" | sudo -S cp -vr "/media/gopro/GoPro MTP Client Disk Volume/DCIM/100GOPRO"/*.MP4 /media/storage/
gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio list -u "$2"GoPro\ MTP\ Client\ Disk\ Volume/DCIM/100GOPRO/")}' | grep '.MP4' | sed '1d;3,10d' | xargs -i gio open {}

sleep 5

gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio mount -u "$2)}'
echo "$SUDOPASS" | sudo -S fusermount -u /media/gopro
sleep 1

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


