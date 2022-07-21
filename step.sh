#!/bin/bash

# Reset the Snowplow collector state
echo "Reset the state of the collector at $collector_url..."
result=$(curl --silent "$collector_url/micro/reset")

# Parse the results
total=$(jq -r '.total' <<< "$result")

# Check the result and produce a summary, mark the step as failed if required
if [[ -z $total ]] || [[ $total -gt 0 ]]
then
  echo "The Snowplow micro failed to reset."
  exit 1
else
  echo "Collector reset successfully"
fi
