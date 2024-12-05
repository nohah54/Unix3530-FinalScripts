#!/bin/bash

# Prompt user to select a date using Zenity calendar picker
date=$(zenity --calendar --title="Select Date for Scheduling" --text="Choose the date to schedule the script." --date-format="%Y-%m-%d")
if [ -z "$date" ]; then
  zenity --error --text="No date selected. Exiting."
  exit 1
fi

# Prompt user to enter time in 12-hour format
time=$(zenity --entry --title="Select Time" --text="Enter the time in HH:MM format (e.g., 02:30):")
if [[ ! $time =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
  zenity --error --text="Invalid time format. Please enter time in HH:MM format."
  exit 1
fi

# Prompt user to select AM or PM
am_pm=$(zenity --list --radiolist --title="AM or PM" --text="Select AM or PM:" \
  --column="Select" --column="Option" TRUE "AM" FALSE "PM")
if [ -z "$am_pm" ]; then
  zenity --error --text="No selection made for AM/PM. Exiting."
  exit 1
fi

# Convert 12-hour time to 24-hour time
hour=$(echo $time | cut -d':' -f1)
minute=$(echo $time | cut -d':' -f2)

if [ "$am_pm" == "PM" ] && [ "$hour" -lt 12 ]; then
  hour=$((hour + 12))
elif [ "$am_pm" == "AM" ] && [ "$hour" -eq 12 ]; then
  hour=0
fi

# Prompt user to select a script file
script_file=$(zenity --file-selection --title="Select Script to Schedule")
if [ -z "$script_file" ]; then
  zenity --error --text="No script file selected. Exiting."
  exit 1
fi

# Ask if DISPLAY and XAUTHORITY variables are needed
use_display=$(zenity --question --text="Does the script require DISPLAY and XAUTHORITY variables? Click 'Yes' if required." \
  --ok-label="Yes" --cancel-label="No")
if [ $? -eq 0 ]; then
  display="DISPLAY=:0"
  xauthority="XAUTHORITY=/home/$USER/.Xauthority"
else
  display=""
  xauthority=""
fi

# Prompt user to select a repetition schedule
repetition=$(zenity --list --radiolist --title="Repetition Schedule" --text="Select repetition schedule:" \
  --column="Select" --column="Option" TRUE "Once a day" FALSE "Once a week" FALSE "Once a month" FALSE "Once a year")
if [ -z "$repetition" ]; then
  zenity --error --text="No repetition schedule selected. Exiting."
  exit 1
fi

# Calculate day and month for the initial run
day=$(date -d "$date" +"%d")
month=$(date -d "$date" +"%m")
weekday=$(date -d "$date" +"%u") # 1=Monday, 7=Sunday

# Determine the cron schedule syntax
case "$repetition" in
  "Once a day")
    cron_time="$minute $hour * * *"
    ;;
  "Once a week")
    cron_time="$minute $hour * * $weekday"
    ;;
  "Once a month")
    cron_time="$minute $hour $day * *"
    ;;
  "Once a year")
    cron_time="$minute $hour $day $month *"
    ;;
esac

# Add the cron job
cron_job="$cron_time $display $xauthority bash $script_file"
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -

# Show confirmation
zenity --info --text="The script has been scheduled successfully.\n\nCron Job:\n$cron_job"
