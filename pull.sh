#!/bin/bash

# TODO Make this work with Windows and not using Bash

GITHUB_USERNAME=$1
EXERCISE_NAME=$2

if [ -z "$GITHUB_USERNAME" ]
then
  echo "Enter your Github username"
  exit 0
fi

if [ -z "$EXERCISE_NAME" ]
then
  echo "Enter your exercise name"
  exit 0
fi

git clone https://github.com/$GITHUB_USERNAME/$EXERCISE_NAME.git
cd $EXERCISE_NAME/
bash ./post-pull.sh

