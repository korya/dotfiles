#!/usr/bin/env bash

function usage() {
  echo "Usage: $0 <submodule-name>"
  echo ""
  echo "Remove <submodule-name> from a repo."
  echo ""
  echo "Options:"
  echo "  -h, --help                Print this message"
  echo "  -v, --verbose             Display verbose output"
}

function main() {
  if [ "${verbose}" == "true" ]; then
    set -x
  fi

  # Remove submodule and commit
  git config -f .gitmodules --remove-section "submodule.${sub}"
  if git config -f .git/config --get "submodule.${sub}.url"; then
    git config -f .git/config --remove-section "submodule.${sub}"
  fi
  rm -rf "${path}"
  git add -A .
  git commit -m "Remove submodule ${sub}"
  rm -rf ".git/modules/${sub}"
}

set -euo pipefail

declare verbose=false
while [ $# -gt 0 ]; do
  case "$1" in
    (-h|--help)
      usage
      exit 0
      ;;
    (-v|--verbose)
      verbose=true
      ;;
    (*)
      break
      ;;
  esac
  shift
done

declare sub="${1:-}"

if [ -z "${sub}" ]; then
  >&2 echo "Error: No submodule specified"
  usage
  exit 1
fi

if [ $# -gt 1 ]; then
  >&2 echo "Error: Unknown option: ${5:-}"
  usage
  exit 1
fi

if ! [ -d ".git" ]; then
  >&2 echo "Error: No git repository found.  Must be run from the root of a git repository"
  usage
  exit 1
fi

declare path="$(git config -f .gitmodules --get "submodule.${sub}.path")"

if [ -z "${path}" ]; then
  >&2 echo "Error: Submodule not found: ${sub}"
  usage
  exit 1
fi

if ! [ -d "${path}" ]; then
  >&2 echo "Error: Submodule path not found: ${path}"
  usage
  exit 1
fi

main
