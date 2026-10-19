#!/bin/bash

# hack to mock git commands as part of action.yaml, driven by env vars so one job can run several scenarios:
#   E2E_CHANGED_FILES        newline-separated files `git diff` reports as changed
#   E2E_MISSING_DIFF_BASE    when "true", `git cat-file` reports the diff base commit as missing

if [[ "$1" == "diff" ]]; then
  printf '%s\n' "$E2E_CHANGED_FILES"
elif [[ "$1" == "fetch" ]]; then
  echo "Handling git fetch, doing nothing"
elif [[ "$1" == "cat-file" ]]; then
  if [[ "$E2E_MISSING_DIFF_BASE" == "true" ]]; then
    exit 1
  fi
  echo "Handling git cat-file, doing nothing"
else
  echo "Error: git mock script isn't configured to handle $1" >&2
  exit 1
fi
