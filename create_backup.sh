#!/bin/bash

# Select a source directory or
# Use Zenity to select a source directory
SOURCE=$(zenity --file-selection --directory --title="Select Source Folder for Backup")
if [ $? -ne 0 ]; then
    zenity --error --text="Source folder selection was canceled -> Exiting!"
    exit 1
fi

# Select the destination folder
# Use Zenity to select the destination folder
DESTINATION=$(zenity --file-selection --directory --title="Select Destination Folder for Backup")
if [ $? -ne 0 ]; then
    zenity --error --text="Destination folder selection was canceled -> Exiting!"
    exit 1
fi


# If using Zeinty check if the user canceled the dialog
if [ -z "$SOURCE" ] || [ -z "$DESTINATION" ]; then
    zenity --error --text="Source or destination folder was not selected -> Exiting!"
    exit 1
fi

# Create a tarball of the source folder and backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$DESTINATION/backup_$(basename "$SOURCE")_$TIMESTAMP.tar.gz"

tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"

# If using Zenity display the success or failure of the backup
if [ $? -eq 0 ]; then
    zenity --info --text="Backup successful! File created at:\n$BACKUP_FILE"
else
    zenity --error --text="Backup failed! - Please check the source and destination folders."
    exit 1
fi