#!/bin/sh

alias source_env="export $(grep -v '^#' .env | xargs -d '\n')"
