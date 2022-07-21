#!/bin/bash

# Helper for finishing and exiting.
#   $0 - A summary message to be printed and exported
#   $1 - The script exit code. Defaults to 0, will be overwritten if $fail_on_error is set to 'no'
finish () {
  summary="$1"
  exit_code="$2"

  # Set the summary as an output for use in future steps
  envman add --key SNOWPLOW_MICRO_COLLECTOR_SUMMARY --value "$summary"

  # Downgrade any errors if fail_on_error is turned off
  if [ "$fail_on_error" = "no" ]
  then
    unset exit_code
  fi

  # Finish and exit with the appropriate code
  echo "$summary"
  exit "${exit_code:-0}"
}

# Reset the Snowplow collector state
echo "Resetting the state of the collector at $collector_url..."
result=$(curl "$collector_url/micro/reset")
echo "Response from the server: '$result'"

# Parse the results
total=$(jq -r '.total' <<< "$result")

# Check the result and produce a summary, mark the step as failed if required
if [[ -z "$total" ]]
then
  finish "Unable to retrieve status from the collector" 1
elif [[ $total -gt 0 ]]
then
  finish "The collector failed to reset" 1
else
  finish "The collector was reset successfully" 0
fi
