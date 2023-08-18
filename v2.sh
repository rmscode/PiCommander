#!/bin/bash

#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Author: @rmscode

# Display a 'spinner' whle running commands
#
#Do NOT call the _spinner function directly. Use {start,stop}_spinner wrapper functions instead.

function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

# Welcome message (todo)
clear;
echo -e "   dBBBBBb  dBP dBBBP  dBBBBP dBBBBBBb  dBBBBBBb dBBBBBb     dBBBBb  dBBBBb  dBBBP dBBBBBb"
echo -e "       dB'            dBP.BP       dBP       dBP      BB        dBP     dBP            dBP"
echo -e "   dBBBP' dBP dBP    dBP.BP dBPdBPdBP dBPdBPdBP   dBP BB   dBP dBP dBP dBP dBBP    dBBBBK" 
echo -e "  dBP    dBP dBP    dBP.BP dBPdBPdBP dBPdBPdBP   dBP  BB  dBP dBP dBP dBP dBP     dBP  BB" 
echo -e " dBP    dBP dBBBBP dBBBBP dBPdBPdBP dBPdBPdBP   dBBBBBBB dBP dBP dBBBBBP dBBBBP  dBP  dB'" 
echo -e "${RED} =======================================================================================${NC}";
echo -e "version 2.0";
echo -e "";
echo -e "Welcome to PiCommander Config Script for PiSignage 3.2.0 (fresh)!
Lets make sure we have all the required packages before moving forward..."

echo -e "Setting clock . . ."
sudo apt-get install -y ntp ntpdate > /dev/null;
sudo systemctl stop ntp
sudo ntpdate 0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org
sudo systemctl start ntp

#Checking packages
echo -e "${YELLOW}Checking packages...${NC}"
echo -e "List of required packages: wget, git, curl, jq, watchdog"

read -r -p "Do you want to check packages? [Y/n]: " response </dev/tty

case $response in
[nN]*)
  echo -e "${RED}
  Packages check is ignored!
  Please be aware that all software packages may not be installed!
  ${NC}"
  ;;

*)
start_spinner "Performing ${GREEN}apt-get update${NC}";
sudo apt-get update > /dev/null;
stop_spinner $?;
WGET=$(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing wget${NC}"
    sudo apt-get install wget --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}wget is installed!${NC}"
  fi
GIT=$(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing git${NC}"
    sudo apt-get install git --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}git is installed!${NC}"
  fi
CURL=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing curl${NC}"
    sudo apt-get install curl --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}curl is installed!${NC}"
  fi
JQ=$(dpkg-query -W -f='jq${Status}' jq 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing jq${NC}"
    sudo apt-get install jq --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}jq is installed!${NC}"
  fi
WATCHDOG=$(dpkg-query -W -f='${Status}' watchdog 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' watchdog 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing watchdog${NC}"
    sudo apt-get install WATCHDOG --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' watchdog 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}watchdog is installed!${NC}"
  fi

  ;;
esac

echo -e ""

# Prompt user for some information
read -p "Enter the name for this PiSignage Player: " piName
echo -e ""
read -p "Enter the time zone for this player (ex 'America/New_York'): " timeZone
echo -e ""

read -r -p "Do you want to enable the On/Off schedule? [Y/n]: " response </dev/tty
if [[ "$response" =~ ^[Nn]$ ]]; then
  onTime=""
  offTime=""
  echo -e "${RED}
  The On/Off schedule will not enabled!
  ${NC}"
else
  echo -e "${GREEN}
  The On/Off schedule will be enabled!
  ${NC}"
  read -p "Enter the time you would like the player to turn on the screen (ex '09:00'): " onTime
  echo -e ""
  read -p "Enter the time you would like the player to turn off the screen (ex '17:00'): " offTime
  echo -e ""
fi

read -r -p "Do you want to enable automatic system reboots? [Y/n]: " response </dev/tty
if [[ "$response" =~ ^[Nn]$ ]]; then
  rebootTime=""
  echo -e "${RED}
  Automatic system reboots will not be enabled!
  ${NC}"
else
  echo -e "${GREEN}
  Automatic system reboots will be enabled!
  ${NC}"
  read -p "Enter the time you would like the player to reboot everyday (ex '00:00'): " rebootTime
  echo -e ""
fi

read -p "Enter the name of the first playlist you would like to create: " playlistName
echo -e ""
read -p "Enter the name of the weblink asset to use with the playlist '$playlistName': " assetName
echo -e ""
read -p "Enter the URL to use with the '$assetName' asset: " assetURL
echo -e ""
read -s -p "Finally, lets choose a new password for the system/WebUI instead of the default: " newPassword
echo -e ""
read -s -p "Confirm new password: " confirmPassword
echo -e ""

if [ "$newPassword" != "$confirmPassword" ]; then
  echo -e "${RED}
  Passwords do not match. Please try again.
  ${NC}"
  exit 1
fi

# Setting the hostname
echo -e "${GREEN}
Setting the hostname to '$piName' . . .
${NC}"

# Setting the time zone
echo -e "${GREEN}
Setting the time zone to '$timeZone' . . .
${NC}"
sudo bash -c 'while read line; do
  if [[ $line == export\ TZ=* ]]; then
    line="export TZ='America/New_York'"
  fi
  echo "$line"
done < /home/pi/.bash_profile > /home/pi/.bash_profile_new
mv /home/pi/.bash_profile_new /home/pi/.bash_profile
timedatectl set-timezone America/New_York'
timedatectl

# Setting the On/Off schedule
if [ -n "$onTime" ]; then
  echo -e "${GREEN}
  Setting the On/Off schedule to '$onTime' - '$offTime' . . .
  ${NC}"
  jq --arg onTime "$onTime" --arg offTime "$offTime" '.sleep |= . + {"ontime": $onTime, "offtime": "18:50", "enable": true, "ontimeObj": "1969-12-31T11:50:00.000Z", "offtimeObj": "1969-12-31T23:50:00.000Z"}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json
fi

# Setting automatic system reboots
if [ -n "$rebootTime" ]; then
   echo -e "${GREEN}
   Setting automatic system reboots to '$rebootTime' . . .
   ${NC}"
   jq --arg rebootTime "${rebootTime}" '.reboot |= . + {"enable": true, "time": "1970-01-01T'"${rebootTime}"':00.000Z", "absoluteTime": "09:00"}' /home/pi/piSignagePro/config/_settings.json > tmp.json && mv tmp.json /home/pi/piSignagePro/config/_settings.json
fi

# Creating playlist
echo -e "${GREEN}
Creating playlist '$playlistName' . . .
${NC}"
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

# Creating asset
echo -e "${GREEN}
Creating weblink asset '$assetName' with url '$assetURL' . . .
${NC}"
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

# Starting the playlist
echo -e "${GREEN}
Starting the playlist '$playlistName' for the first time. This will make it the default playlist that starts when the player boots up.
${NC}"
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Basic cGk6cGK=" -d '{"play": "true"}' http://localhost:8000/api/play/playlists/$playlistName | jq .
echo -e ""


# Changing the system and WebUI password
echo -e "Changing the system/WebUI password . . ."
echo "pi:$newPassword" | sudo chpasswd
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Basic cGk6cGK=" -d "{\"user\": {\"name\": \"pi\", \"newpasswd\": \"$newPassword\"}}" http://localhost:8000/api/settings/user | jq .
echo -e ""

# Make the watchdog-config.sh script executable
sudo chmod +x /home/pi/PiCommander/scripts/watchdog-config.sh

# Enable the watchdog timer
echo -e "${GREEN}
Enabling the watchdog timer . . .
${NC}"
sudo bash -c 'echo "dtparam=watchdog=on" >> /boot/config.txt'
echo -e ""

# Create cron job to execute watchdog-config.sh after reboot
echo -e "${GREEN}
Creating cron job to execute watchdog-config.sh after rebooting . . .
${NC}"
sudo bash -c '(crontab -l ; echo "@reboot /home/pi/PiCommander/scripts/watchdog-config.sh") | crontab -'
echo -e ""

echo -e "${GREEN}
We're finished! The system will reboot in 5 seconds.
${NC}"
sleep 5
sudo reboot now

