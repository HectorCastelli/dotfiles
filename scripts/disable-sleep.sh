#!/bin/sh

echo "This will disable sleep on a linux machine."
echo "This affects the following systemd targets:
    - sleep.target
    - suspend.target
    - hibernate.target
    - hybrid-sleep.target
"

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target