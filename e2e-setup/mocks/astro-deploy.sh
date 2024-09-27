#!/bin/bash

# pre-req for this mock script would be to have the actual astro cli installed at /usr/local/bin/astro-original

if [ "$1" = "deploy" ]; then
    # Change directory to 'e2e-setup/astro-project' and then call original `astro deploy`
    # so that we could simulate the default behavior without needing to have the astro project in base folder
    echo "cd into astro project" && cd e2e-setup/astro-project && /usr/local/bin/astro-original "$@"
else
    # If it's not a `deploy` command, run the original `astro`
    /usr/local/bin/astro-original "$@"
fi