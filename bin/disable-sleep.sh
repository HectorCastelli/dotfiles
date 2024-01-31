#!/bin/sh

disable_sleep() {
    warn "This will disable sleep on a linux machine."
    debug "This affects the following systemd targets:
        - sleep.target
        - suspend.target
        - hibernate.target
        - hybrid-sleep.target
    "
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
}

reenable_sleep() {
    warn "This will re-enable sleep on a linux machine."
    sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target

}
