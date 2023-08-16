#!/bin/bash

# Install jq, a command line JSON processor
sudo apt-get install jq -y
wait

# Make watchdog-config.sh executable
sudo chmod +x /home/pi/PiCommander/scripts/watchdog-config.sh

# Change the TZ value in .bash_profile
# We do this because chromium appears to read the timezone from here
while read line; do
  if [[ $line == export\ TZ=* ]]; then
    line="export TZ='America/New_York'"
  fi
  echo "$line"
done < /home/pi/.bash_profile > /home/pi/.bash_profile_new

# Replace the original .bash_profile file with the updated one
mv /home/pi/.bash_profile_new /home/pi/.bash_profile

# Change the system timezone
sudo timedatectl set-timezone America/New_York

# Parse _settings.json file and modify the automatic reboot setting - 00:00 AM every day
jq '.reboot |= . + {"enable": true, "time": "1970-01-01T00:00:00.000Z", "absoluteTime": "09:00"}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json

# Parse command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--password)
    PASSWORD="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    shift # past argument
    ;;
esac
done

# Change the password for the user pi
while true; do
  if [ -z "$PASSWORD" ]; then
    read -s -p "Enter new password for pi user: " password1
    echo
    read -s -p "Confirm new password for pi user: " password2
    echo
    if [ "$password1" = "$password2" ]; then
      echo "Passwords match"
      break
    else
      echo "Passwords do not match. Please try again."
    fi
  else
    password1="$PASSWORD"
    password2="$PASSWORD"
    break
  fi
done

echo "pi:$password1" | sudo chpasswd

# Enable the watchdog timer
sudo sh -c 'echo "dtparam=watchdog=on" >> /boot/config.txt'

# Create cron job to execute watchdog-config.sh after reboot
(crontab -l ; echo "@reboot /home/pi/PiCommaner/scripts/watchdog-config.sh") | crontab -
sudo reboot now

