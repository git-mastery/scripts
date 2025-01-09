#!/bin/bash

# TODO Make this work with Windows and not using Bash

GITHUB_USERNAME=$1
EXERCISE_NAME=$2

git pull https://github.com/$1/$EXERCISE_NAME.git
cd $EXERCISE_NAME/
bash ./post-pull.sh

