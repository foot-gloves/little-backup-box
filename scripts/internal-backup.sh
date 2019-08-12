#!/usr/bin/env bash

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

# IMPORTANT:
# Run the install-little-backup-box.sh script first
# to install the required packages and configure the system.

CONFIG_DIR=$(dirname "$0")
CONFIG="${CONFIG_DIR}/config.cfg"

source "$CONFIG"

# Set the ACT LED to heartbeat
sudo sh -c "echo heartbeat > /sys/class/leds/led0/trigger"

# Set Power LED to heartbeat
# sudo sh -c "echo heartbeat > /sys/class/leds/led1/trigger"

# Wait for a USB storage device (e.g., a USB flash drive)
STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
while [ -z ${STORAGE} ]
  do
  sleep 1
  STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
done

# When the USB storage device is detected, mount it
mount /dev/"$STORAGE_DEV" "$STORAGE_MOUNT_POINT"

# Set the ACT LED to blink at 1000ms to indicate that the storage device has been mounted
sudo sh -c "echo timer > /sys/class/leds/led0/trigger"
sudo sh -c "echo 1000 > /sys/class/leds/led0/delay_on"

# Create  a .id random identifier file if doesn't exist
cd "$STORAGE_MOUNT_POINT"
if [ ! -f *.id ]; then
  random=$(echo $RANDOM)
  touch $(date -d "today" +"%Y%m%d%H%M")-$random.id
fi
ID_FILE=$(ls *.id)
ID="${ID_FILE%.*}"
cd

# Set the backup path
BACKUP_PATH="$BAK_DIR"/"$ID"
# Perform backup using rsync
rsync -av "$STORAGE_MOUNT_POINT"/ "$BACKUP_PATH"

# Turn off the ACT LED to indicate that the backup is completed
sudo sh -c "echo 0 > /sys/class/leds/led0/brightness"


# Set Power LED to heartbeat to indicate start of rclone
# sudo sh -c "echo heartbeat > /sys/class/leds/led1/trigger"

# Copy contents of back up directory to gdrive via rclone
# sudo rclone copy "$BACKUP_PATH" CAMERADUMP:/


# Remove contents of back up directory

# find: the unix command for finding files / directories / links etc.
# /path/to/base/dir: the directory to start your search in.
# -type d: only find directories
# -ctime +1: only consider the ones with modification time older than 1 days
# -exec ... \;: for each such result found, do the following command in ...
# rm -rf {}: recursively force remove the directory; the {} part is where the find result gets substituted into from the previous part.

# sudo find /path/to/base/dir/* -type d -ctime +1 -exec rm -rf {} \;


# Shutdown
sync
shutdown -h now
