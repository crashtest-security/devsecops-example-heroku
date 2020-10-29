#!/usr/bin/env bash

#### Setup variables ####

# Stop the script as soon as the first command fails
set -euo pipefail

# Set WEBHOOK to webhook secret (without URL)
WEBHOOK=$1

# Set the API endpoint
API_ENDPOINT="https://api.crashtest.cloud/webhook"

#### Setup the alpine system ####
apk add curl jq libxml2-utils
mkdir -p ~/crashtest

#### Start Security Scan ####

# Start Scan and get scan ID
SCAN_ID=`curl --silent -X POST --data "" $API_ENDPOINT/$WEBHOOK | jq .data.scanId`
echo "Started Scan for Webhook $WEBHOOK. Scan ID is $SCAN_ID."


#### Check Security Scan Status ####

# Set status to Queued (100)
STATUS="100"

# Run the scan until the status is not queued (100) or running (101) anymore
while [[ $STATUS -le "101" ]]
do
   echo "Scan Status currently is $STATUS (101 = Running)"

   # Only poll every minute
   sleep 60

   # Refresh status
   STATUS=`curl --silent $API_ENDPOINT/$WEBHOOK/scans/$SCAN_ID/status | jq .data.status.status_code`

done

echo "Scan finished with status $STATUS."


#### Download Scan Report ####

curl --silent $API_ENDPOINT/$WEBHOOK/scans/$SCAN_ID/report/junit -o ~/crashtest/report.xml
echo "Downloaded Report to crashtest/report.xml"

# Count XSS findings
FINDINGS_COUNT=`xmllint --xpath 'count(//testcase[@classname="xss.crashtest.cloud"]/failure)' ~/crashtest/report.xml`	

echo "Found $FINDINGS_COUNT XSS findings. Test will fail if at least one XSS finding is present."	

# Check if at least one XSS finding has been found
if [[ ${FINDINGS_COUNT} -ge "1" ]]; then exit 1; else exit 0; fi
