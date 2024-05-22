#!/bin/bash

interface=$PT_interface
runs=$PT_runs

echo "Configuring interface $interface with $runs runs."

for ((i=1; i<=runs; i++))
do
  echo "Run $i: Configuring $interface..."
  # Add your configuration commands here
done
