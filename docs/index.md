# About
A simple set of scripts that will automate some basic system configuration tasks for a fresh install of [PiSignage](https://github.com/colloqi/pisignage) on a Raspberry Pi. Tested on a Raspberry Pi 3 and 4 running PiSignage 3.2.0.

## Features
- [x] Installs a few packages. Namely, jq for parsing json and watchdog for automatic system recovery after a kernel panic.
- [x] Guides user through the process of creating a playlist and asset settings.
- [x] Guides the user through configuring various PiSignage settings.
- [x] Prompts the user to change the default system & WebUI password.
- [x] Enables and configures the watchdog service.
- [x] Self cleaning . . . removes cloned PiCommander directory from the system after running.


