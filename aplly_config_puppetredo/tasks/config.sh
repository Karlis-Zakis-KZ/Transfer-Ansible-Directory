#!/bin/sh
for parent in "$parents"; do
  vtysh -c "$parent"
done

for line in "$lines"; do
  vtysh -c "$line"
done
