# About
A simple set of scripts that will automate some basic system configuration tasks for a fresh install of PiSignage on a Raspberry Pi. Tested on a Raspberry Pi 3 and 4 running PiSignage 3.2.0.

## Features
- [x] Sets system & bash_profile timezone to "America/New_York" (change as needed)
- [x] Modifies _settings.json to enable automatic daily reboots
- [x] Enables and configures the watchdog timer for automatic rebooting if the system hangs
- [x] Prompts user to change default system password
- [x] Self cleaning . . . removes itself from the system after running 

# Usage
1. Clone the repository using git or github cli. (git is probably already installed by default)
   1. Git: `git clone https://github.com/rmscode/PiCommander.git`
   2. Github CLI: `gh repo clone rmscode/PiCommander`
2. Make the script executable: `sudo chmod +x PiCommander/scripts/piPlayer-config.sh`
3. Run the script: `./PiCommader/scripts/piPlayer-config.sh`
