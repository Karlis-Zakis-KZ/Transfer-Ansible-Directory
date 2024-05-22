#!/bin/bash

# Activate the virtual environment
source /home/osboxes/Transfer-Ansible-Directory/boltFiles/bolt_project/venv/bin/activate

# Run the Python script with the provided parameters
python /home/osboxes/Transfer-Ansible-Directory/boltFiles/bolt_project/network_config_with_capture.py "$PT_interface" "$PT_runs" "/home/osboxes/Transfer-Ansible-Directory/boltFiles/bolt_project/hosts.txt"
