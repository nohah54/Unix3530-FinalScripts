#!/bin/bash

# Use Zenity to prompt user to select the script (.sh file) to run and store in a variable
script=$(zenity --file-selection --title="Select a Script to Run" --file-filter="*.sh")

# If no script is selected, exit
if [ -z "$script" ]; then
    zenity --error --text="No script was selected. Exiting."
    exit 1
fi

# Use Zenity to prompt user to select an image to use as the icon and store in a variable
icon=$(zenity --file-selection --title="Select an Image" --file-filter="*.png *.jpg *.jpeg")

# If no image is selected, exit
if [ -z "$icon" ]; then
    zenity --error --text="No image was selected. Exiting."
    exit 1
fi

# Use Zenity to prompt user to enter a name for the desktop entry and store in a variable
name=$(zenity --entry --title="Enter a Name for the Desktop Icon" --text="Enter a name for the desktop icon:")

# If no name is entered, use a default name
if [ -z "$name" ]; then
    name="CustomerIcon"
fi

# Define the path for the .desktop file (in the current directory) and store in a variable
desktop_file="$HOME/Desktop/$name.desktop"

# Create the .desktop file using echo commands
# You can echo the content with the variables that you created
# using all the variables that were stored for path
# and zenity. The first line will be redirected >
# the following lines will be added with >>
echo "[Desktop Entry]" > "$desktop_file"    # This defines the file as a Desktop Entry
echo "Version=1.0" >> "$desktop_file"   # This specifies the desktop entry version
echo "Type=Application" >> "$desktop_file"    # This indicates that the entry represents an application
echo "Name=$name" >> "$desktop_file"    # This sets the name of the icon that was entered by the user
echo "Exec=bash \"$script\"" >> "$desktop_file"    # This specifies the command used to execute the selected script
echo "Icon=$icon" >> "$desktop_file"    # This sets the path of the image file to use as the icon
echo "Terminal=true" >> "$desktop_file"    # This indicates whehter the application should run in a terminal
echo "Categories=Utility;" >> "$desktop_file"   # This categorizes the desktop entry as a utility


# Copy the .desktop file to the user's desktop
cp "$desktop_file" "$HOME/Desktop/"

# Make the .desktop file executable
chmod +x "$desktop_file"

# Use Zenity to notify user that the .desktop file has been created and moved
zenity --info --text="Desktop Icon '$name' created and moved to your desktop."