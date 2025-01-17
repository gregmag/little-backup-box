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

sleep 2
echo "$SUDOPASS" | sudo -S umount /media/storage
sleep 2
echo "$SUDOPASS" | sudo -S umount /media/HBSYL
sleep 2
echo "$SUDOPASS" | sudo -S fusermount -u /media/gopro
sleep 2
gio mount -li | awk -F= ' {if(index($2,"mtp") == 1)system("gio mount -u "$2)}'
clear

echo "Bonjour cher pilote"
echo ""
echo "Ceci est le programme d'EFFACEMENT de caméra et stick et NON pas celui de copie"
echo ""
echo ""
echo "Vous avez 30 secondes pour déconnecter la caméra ou le le stick avant EFFACEMENT"
echo "Si c'est bien ce que vous voulez, patientez ..."
sleep 30

#read -p "Êtes-vous sûr de vouloir continuer ? (tapez O pour oui ou n'importe quelle touche suivie de ENTER pour quitter) "

#if [[ $REPLY =~ ^[0Oo]$ ]]
#then

echo ""
#read -p "Voulez-vous effacer la caméra (c), le stick (s) ? "

#if [[ $REPLY =~ ^[Ss]$ ]]
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
echo "$SUDOPASS" | sudo -S mkfs.fat -n USBDISK /dev/sda1

sleep 3
echo "$SUDOPASS" | sudo -S umount /media/storage
sleep 2
echo "$SUDOPASS" | sudo -S umount /media/pi/HBSYL
sleep 2
echo "$SUDOPASS" | sudo -S umount /media/HBSYL
sleep 2
echo "$SUDOPASS" | sudo -S umount /media/USBDISK
sleep 2
echo "$SUDOPASS" | sudo -S udisksctl power-off -b /dev/sda


#elif [[ $REPLY =~ ^[Cc]$ ]]
#then

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


#echo "$SUDOPASS" | sudo -S gphoto2 --delete-all-files -f /store_00000004/DCIM --recurse
echo 'y' | mtp-format

sleep 5
echo "$SUDOPASS" | sudo -S fusermount -u /media/gopro

#fi

#fi

clear

echo "Terminé !"
echo "Vous pouvez débrancher la caméra et/ou le stick USB"
echo " "

sleep 30
#read -p "Pressez une touche pour fermer cette fenêtre ..."

# Power off
if [ $POWER_OFF = true ]; then
    poweroff
fi


