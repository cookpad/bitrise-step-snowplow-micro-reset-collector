#!/bin/bash

# Reset the Snowplow collector state
echo "Resetting the state of the collector at $collector_url..."
result=$(curl "$collector_url/micro/reset")
echo "Response from the server: '$result'"

# Parse the results
total=$(jq -r '.total' <<< "$result")

# Check the result and produce a summary, mark the step as failed if required
if [[ -z $total ]] || [[ $total -gt 0 ]]
then
  exit_code=1
  summary="The collector failed to reset"
else
  summary="The collector was reset successfully"
fi

# Set the summary as an output for use in future steps
envman add --key SNOWPLOW_MICRO_COLLECTOR_SUMMARY --value "$summary"

# Downgrade any errors if fail_for_bad_reset is turned off
if [ "$fail_for_bad_reset" = "no" ]
then
  unset exit_code
fi

# Finish and exit with the appropriate code
echo "$summary"
exit "${exit_code:-0}"
