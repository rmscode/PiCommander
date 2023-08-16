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

# Create a default playlist
cat > /home/pi/media/__Default_Playlist.json<< EOF
{
    "name": "Default_Playlist",
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
            "filename": "Default_Asset.weblink",
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
cat > /home/pi/media/Default_Asset.weblink<< EOF
{
    "name": "Default_Asset",
    "type": ".weblink",
    "link": "https://google.com",
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

# Create a default playlist
cat > /home/pi/media/__Default_Playlist.json<< EOF
{
    "name": "Default_Playlist",
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
            "filename": "Portal_TV_Page.weblink",
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