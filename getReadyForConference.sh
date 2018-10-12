#!/usr/bin/env bash

set -e

RUN_DOCKER="${RUN_DOCKER:-yes}"

function print_logs() {
    echo -e "\n\nSOMETHING WENT WRONG :( :( \n\n"
    echo -e "\n\nPRINTING LOGS FROM ALL APPS\n\n"
    tail -n +1 -- sleuth-documentation-apps/build/*.log
}

function fail_with_message() {
    echo -e $1
    print_logs
    exit 1
}

# Kill the running apps
./sleuth-documentation-apps/scripts/kill.sh && echo "Killed some running apps" || echo "No apps were running"

# First run the `./setupPresentationRepo.sh` to initialize the GIT submodule.
./setupPresentationRepo.sh

# Next run the `./runApps.sh` script to initialize Zipkin and the apps (check the `README` of `sleuth-documentation-apps` for Docker setup info)
./runApps.sh

# Next start the ELK docker with `docker-compose up`
if [[ "${RUN_DOCKER}" == "yes" ]] ; then
    yes | docker-compose kill
    docker-compose build
    docker-compose up -d
else
    echo -e "\n\nSkipping docker setup"
fi

sleepTime=30
echo -e "\n\nWaiting for [${sleepTime}] seconds for ELK stack to start\n\n"
sleep "${sleepTime}"

echo -e "\n\nReady to curl first request"

./sleuth-documentation-apps/scripts/curl_start.sh || fail_with_message "Failed to send the request"

echo -e "\n\nReady to curl a request that will cause an exception"

./sleuth-documentation-apps/scripts/curl_exception.sh && fail_with_message "\n\nShould have failed the request but didn't :/" || echo -e "\n\nSent a request and got an exception!"
