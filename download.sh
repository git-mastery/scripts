#!/bin/bash

set -e

log_step() {
  echo "[INFO] $1"
}

error_exit() {
  echo "[ERROR] $1" >&2
  exit 1
}

check_binary() {
  if ! which "$1" >/dev/null; then
    error_exit "$2"
  fi
}

log_step "Welcome to Git-Mastery!"
log_step "We are ensuring that you have both Git and Github CLI installed"

# Check required binaries
check_binary "git" "You need to install Git"
check_binary "gh" "You need to install the GitHub CLI"

# Check GitHub authentication
if ! gh auth status >/dev/null 2>&1; then
  error_exit "You aren't logged into GitHub CLI. Run 'gh auth login' to login."
fi

EXERCISE_NAME=$1

if [[ -z $EXERCISE_NAME ]]; then
  error_exit "Provide a valid exercise name"
fi

log_step "Downloading $EXERCISE_NAME..."

if [[ -f .org_name ]]; then
  org_name=$(cat .org_name)
  log_step "Forking exercise '$EXERCISE_NAME' to organization '$org_name'"
  gh repo fork git-mastery/$EXERCISE_NAME --org "$org_name" --clone -- --quiet >/dev/null 2>&1
else
  ORG=$2
  if [[ -z $ORG ]]; then
    log_step "Forking exercise '$EXERCISE_NAME' to your GitHub account"
    gh repo fork git-mastery/$EXERCISE_NAME --clone -- --quiet >/dev/null 2>&1
  else
    log_step "Forking exercise '$EXERCISE_NAME' to organization '$ORG'"
    gh repo fork git-mastery/$EXERCISE_NAME --org "$ORG" --clone -- --quiet >/dev/null 2>&1
  fi
fi

cd "$EXERCISE_NAME"

log_step "Setting up repository"
bash ./post-download.sh >/dev/null 2>&1

gh repo set-default "$(gh repo view --json nameWithOwner -q .nameWithOwner)" >/dev/null 2>&1

log_step "Done! Ready to work on '$EXERCISE_NAME'?"
log_step "Run the following and get started:"
log_step "cd $EXERCISE_NAME"
