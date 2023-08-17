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

## BEGIN Modifying _settings.json file

# Configure the on/off schedule
jq '.sleep |= . + {"ontime": "06:50", "offtime": "18:50", "enable": true, "ontimeObj": "1969-12-31T11:50:00.000Z", "offtimeObj": "1969-12-31T23:50:00.000Z"}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json

# Configure automatic reboots
jq '.reboot |= . + {"enable": true, "time": "1970-01-01T00:00:00.000Z", "absoluteTime": "09:00"}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json

# Set the player hostname 
jq '. |= . + {"localName": "PiPlayer"}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json

# Set the player note
jq '. |= . + {"note": ". . ."}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json

# Configure the wifi settings
jq '. |= . + {"wifi": {"ip": null, "countryCode": "US", "apmode": "NO"}}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json

# Configure overscan
jq '. |= . + {"overscan": {"horizontal": 0, "vertical": 0, "disable_overscan": true}}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json

## END modifying _settings.json file

# Prompt user for name of first playlist and store in variable
read -p "Enter the name of the first playlist you would like to create: " playlistName

# Prompt user for the name of the weblink asset for the playlist and store in variable
read -p "Enter the name of a weblink asset to use with the playlist $playlistName: " assetName

# Prompt the user for the URL of the weblink asset and store in variable
read -p "Enter a URL to use with the $assetName asset: " assetURL

# Create a default playlist
cat > /home/pi/media/__$playlistName.json<< EOF
{
    "name": "$playlistName",
    "settings": {
        "ticker": {
            "enable": false,
            "behavior": "scroll",
            "textSpeed": 3,
            "rss": {
                "enable": false,
                "link": null,
                "feedDelay": 10
            }
        },
        "ads": {
            "adPlaylist": false,
            "adCount": 1,
            "adInterval": 60
        },
        "audio": {
            "enable": false,
            "random": false,
            "volume": 50
        }
    },
    "assets": [
        {
            "filename": "$assetName.weblink",
            "duration": 46800,
            "selected": true,
            "option": {
                "main": false
            },
            "dragSelected": true,
            "fullscreen": true
        }
    ],
    "layout": "1",
    "templateName": "custom_layout.html",
    "schedule": {},
    "version": 2,
    "videoWindow": null,
    "zoneVideoWindow": {},
    "groupIds": null
}
EOF

# Create a default asset
cat > /home/pi/media/$assetName.weblink<< EOF
{
    "name": "$assetName",
    "type": ".weblink",
    "link": "$assetURL",
    "duration": null,
    "hideTitle": "title",
    "zoom": 1,
    "weblinkHeaders": ""
}
EOF

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
(crontab -l ; echo "@reboot /home/pi/PiCommander/scripts/watchdog-config.sh") | crontab -
sudo reboot now

