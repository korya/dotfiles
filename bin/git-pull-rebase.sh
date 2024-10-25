#!/usr/bin/env bash

set -e
# set -x

branch="$(git branch --show-current)"

# Prioritize branch names:
# 1. dev (some repos at Klue use dev)
# 2. main (other repos at Klue use main)
# 3. master
master_branch=master
if [[ -n "$(git branch --list dev)" ]]; then
  master_branch="dev"
elif [[ -n "$(git branch --list main)" ]]; then
  master_branch="main"
fi

has_changes=
if [[ -n "$(git diff --stat)" ]]; then
  has_changes=1
fi

if [[ -n "${has_changes}" ]]; then
  git stash
fi
if [[ "${branch}" != "${master_branch}" ]]; then
  git checkout "${master_branch}"
fi

git pull

if [[ "${branch}" != "${master_branch}" ]]; then
  git checkout "${branch}"
  git rebase "${master_branch}"
fi
if [[ -n "${has_changes}" ]]; then
  git stash apply
fi

