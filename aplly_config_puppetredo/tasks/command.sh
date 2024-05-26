#!/bin/sh
for cmd in "$commands"; do
  vtysh -c "$cmd"
done
