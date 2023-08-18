# About
A simple set of scripts that will automate some basic system configuration tasks for a fresh install of [PiSignage](https://github.com/colloqi/pisignage) on a Raspberry Pi. Tested on a Raspberry Pi 3 and 4 running PiSignage 3.2.0.

## Features
- 
- [x] Installs a few packages. Namely, jq for parsing json and watchdog for automatic reboots after a kernel panic.
- [x] Guides user through the process of creating a playlist and asset among other things.
- [x] Prompts the user to change the default system & WebUI password.
- [x] Enables and configures the watchdog service.
- [x] Self cleaning . . . removes cloned PiCommander directory from the system after running.

# Usage
1. Clone the repository using git or github cli. (git should be installed by default)
   1. Git: `git clone https://github.com/rmscode/PiCommander.git`
   2. Github CLI: `gh repo clone rmscode/PiCommander`
2. Make the script executable: `chmod +x PiCommander/scripts/piPlayer-config.sh`
3. Run the script: `./PiCommader/scripts/piPlayer-config.sh`
