#!/bin/bash

# Activate the virtual environment
source /path/to/your/venv/bin/activate

# Run the Python script with the provided parameters
python ~/Transfer-Ansible-Directory/boltFiles/bolt_project/tasks/network_config_with_capture.py "$PT_interface" "$PT_runs" "~/Transfer-Ansible-Directory/boltFiles/bolt_project/hosts.txt"
