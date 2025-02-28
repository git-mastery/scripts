#!/bin/bash

# TODO maybe this should be a dedicated CLI instead of a complex Bash script

set -e

check_binary() {
  if ! which "$1" >/dev/null; then
    (>&2 echo "$2")
    exit 1
  fi
}

# TODO Maybe check if Github connection is working as well?
check_binary "git" "You need to install Github"
check_binary "gh" "You need to install the Github CLI"

if ! gh auth status >/dev/null 2>&1; then
  echo "You aren't logged in to Github CLI yet. Run gh auth login to login"
  exit 1
fi

EXERCISE_NAME=$1

if [[ -z $EXERCISE_NAME ]]; then
  echo "Provide a valid exercise name"
  exit 1
fi

if [[ -f ../.org_name ]]; then
  # If .org_name is found using the Git Mastery setup, we use that instead
  org_name=$(cat ../.org_name)
  echo "Forking exercise to $org_name"
  gh repo fork git-mastery/$EXERCISE_NAME --org $org_name --clone
else
  ORG=$2
  if [[ -z $ORG ]]; then
    echo "Forking exercise to your Github account"
    gh repo fork git-mastery/$EXERCISE_NAME --clone
  else
    echo "Forking exercise to $ORG"
    gh repo fork git-mastery/$EXERCISE_NAME --org $ORG --clone
  fi
fi

cd $EXERCISE_NAME
bash ./post-download.sh
gh repo set-default -u
