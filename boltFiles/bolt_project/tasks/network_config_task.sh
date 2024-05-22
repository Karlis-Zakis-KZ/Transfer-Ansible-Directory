#!/bin/bash

interface=$PT_interface
runs=$PT_runs

echo "interface: $interface"
echo "runs: $runs"

for ((i=1; i<=runs; i++))
do
  # Use network device specific command execution here
  echo "Run $i: Configuring interface $interface..."
  # Example command to configure an interface
  echo "interface $interface" > /dev/null
done
