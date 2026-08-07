#!/bin/bash

# hack to mock git commands as part of action.yaml so that we could simulate a named DAG bundle deploy scenario without making any additional commits.
# the changed file sits under the bundle's dags-path rather than the project's default dags/ folder, so it only classifies as a DAG change when dags-path is honored.

# Check if the script was invoked with "git diff"
if [[ "$1" == "diff" ]]; then
  echo "e2e-setup/astro-project/teams/a/dags/team_a_dag.py"
elif [[ "$1" == "fetch" ]]; then
  echo "Handling git fetch, doing nothing"
elif [[ "$1" == "cat-file" ]]; then
  echo "Handling git cat-file, doing nothing"
else
  echo "Error: git mock script isn't configured to handle $1" >&2
  exit 1
fi
