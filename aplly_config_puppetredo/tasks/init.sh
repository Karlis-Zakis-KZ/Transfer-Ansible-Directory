#!/bin/sh

commands=$(echo "$PT_commands" | jq -r '.[]')

for cmd in $commands; do
  output=$(some_command_execution_tool "$cmd")
  echo $output
done
