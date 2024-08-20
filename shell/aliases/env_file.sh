#!/bin/sh

alias load_dotenv="export $(grep -v '^#' .env | xargs -d '\n')"
