#!/bin/bash

set -x  # Enable debugging output

# Assign parameters to variables
interface=$PT_interface
runs=$PT_runs

# Ensure interface and runs are set
if [[ -z "$interface" || -z "$runs" ]]; then
  echo "Both interface and runs parameters must be provided."
  exit 1
fi

# Loop for the number of runs and configure the interface
for ((i=1; i<=runs; i++))
do
  echo "Run $i: Configuring interface $interface"
  # Example: Send a command to configure the interface
  # Note: Actual Cisco configuration commands should be used here
  # This is a placeholder echo to simulate the command
  echo "interface $interface"
  echo "description 'Configured by Puppet Bolt Run $i'"
done

set +x  # Disable debugging output
