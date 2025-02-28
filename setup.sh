#!/bin/bash

# This is an all-in-one setup script for setting up Git Mastery for your local machine.
# Do not touch anything in here.

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

echo "Welcome to Git Mastery! We will be setting up several components of Git Mastery to ensure an optimal experience working on the various problem sets."
read -p "What do you want to name your problem sets directory? (problem-sets) " directory_name

if [[ -z $directory_name ]]; then
  directory_name="problem-sets"
fi

while true; do
  read -p "Do you want to create a dedicated Github organization to store all of your problem set attempts? (y/n) " create_organization
  case $create_organization in
  [YyNn]*) break ;;
  *) echo "Please answer y/n" ;;
  esac
done

([[ $create_organization == "y" ]] || [[ $create_organization == "Y" ]]) && to_create_organization=true || to_create_organization=false

CURRENT_USERNAME=$(gh api user -q ".login")

if [[ $to_create_organization == true ]]; then
  printf "Github CLI currently does not support creating organizations on your behalf.\nPlease follow these instructions to create an organization: https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch\n"
  read -p "Enter the name for the Github organization " org_name

  if ! gh api -H "Accept: application/vnd.github+json" /user/orgs --jq ".[].login" | grep -w $org_name -q; then
    echo "You do not have the right permissions to fork repositories to this organization or this organization does not exist."
    exit 1
  fi
fi

problem_set_directory=$(pwd)/$directory_name

while true; do
  if [[ $to_create_organization == true ]]; then
    printf "Please confirm that you wish to:\n\t1. Create the Git Mastery folder under \e[1m$problem_set_directory\e[0m\n\t2. Store all your problem sets under organization \e[1m$org_name\e[0m\nConfirm (y/n) "
  else
    printf "Please confirm that you wish to:\n\t1. Create the Git Mastery folder under \e[1m$problem_set_directory\e[0m\nConfirm (y/n) "
  fi

  read confirmation
  case $confirmation in
  [Yy]*) break ;;
  [Nn]*)
    echo "Cancelling Git Mastery setup."
    exit 1
    ;;
  *) echo "Please answer y/n" ;;
  esac
done

mkdir -p $problem_set_directory
cd $problem_set_directory
if [[ $to_create_organization == true ]]; then
  echo -n $org_name >.org_name
fi
curl -O https://raw.githubusercontent.com/git-mastery/scripts/refs/heads/main/download.sh
curl -O https://raw.githubusercontent.com/git-mastery/scripts/refs/heads/main/usage.md
chmod +x download.sh

echo "Running diagnostic to ensure that Git Mastery is properly setup."

bash download.sh diagnostic
cd diagnostic
git commit -m "Test commit" --allow-empty
bash submit.sh

CURRENT_USERNAME=$(gh api user -q ".login")

printf "Visit https://github.com/git-mastery/diagnostic/pulls and find \e[1m[$CURRENT_USERNAME] [diagnostic] Submission\e[0m. If the Github workflow is successful, Git Mastery is successful!\n"

cd ../

printf "We have setup your local environment for Git Mastery! Refer to \e[1musage.md\e[0m for more information about how to use Git Mastery.\n"
