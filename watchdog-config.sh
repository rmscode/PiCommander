#!/bin/bash

sudo su
echo 'watchdog-device = /dev/watchdog' >> /etc/watchdog.conf
echo 'watchdog-timeout = 15' >> /etc/watchdog.conf
echo 'max-load-1 = 24' >> /etc/watchdog.conf
echo 'RuntimeWatchdogSec=10' >> /etc/systemd/system.conf
echo 'ShutdownWatchdogSec=10min' >> /etc/systemd/system.conf
systemctl enable watchdog
systemctl start watchdog

# Cleanup
(crontab -l | grep -v "/home/pi/PiCommander/scripts/watchdog-config.sh") | crontab -
rm -rf /home/pi/PiCommander
