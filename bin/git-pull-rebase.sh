#!/usr/bin/env bash

set -e
# set -x

branch="$(git branch --show-current)"

has_changes=
if [[ -n "$(git diff --stat)" ]]; then
  has_changes=1
fi

if [[ -n "${has_changes}" ]]; then
  git stash
fi
if [[ "${branch}" != "master" ]]; then
  git checkout master
fi

git pull

if [[ "${branch}" != "master" ]]; then
  git checkout "${branch}"
  git rebase master
fi
if [[ -n "${has_changes}" ]]; then
  git stash apply
fi

