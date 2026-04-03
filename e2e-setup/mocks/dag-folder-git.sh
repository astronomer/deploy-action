#!/bin/bash

# hack to mock git commands as part of action.yaml so that we could simulate the dag-folder scenario
# where DAGs live outside root-folder in version control (e.g., at dags/ instead of e2e-setup/astro-project/dags/)

# Check if the script was invoked with "git diff"
if [[ "$1" == "diff" ]]; then
  echo "dags/exampledag.py"
elif [[ "$1" == "fetch" ]]; then
  echo "Handling git fetch, doing nothing"
elif [[ "$1" == "cat-file" ]]; then
  echo "Handling git cat-file, doing nothing"
else
  echo "Error: git mock script isn't configured to handle $1" >&2
  exit 1
fi
