#!/bin/sh

prepare_executables() {
    find . -type f -name "*.sh" -exec chmod +x {} \;
}
