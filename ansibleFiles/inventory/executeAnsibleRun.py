import subprocess
import time
import json
import random
import re

# Function to generate a random IP range and wildcard mask
def generate_ip_range():
    ip_base = f"192.168.{random.randint(0, 255)}.0"
    wildcard_mask = "0.0.255.255"
    return ip_base, wildcard_mask

# Function to get the number of packets sent using ifconfig
def get_packets_sent(interface="ens33"):
    result = subprocess.run(
        ["ifconfig", interface],
        capture_output=True,
        text=True
    )
    match = re.search(r"TX packets (\d+)", result.stdout)
    if match:
        return int(match.group(1))
    return 0

# Function to run the Ansible playbook
def run_playbook(ip_range, wildcard_mask, interface, inventory):
    start_time = time.time()

    # Capture packets sent before running the playbook
    initial_packets_sent = get_packets_sent(interface)

    # Run the ansible playbook with the given variables and inventory
    result = subprocess.run(
        [
            "ansible-playbook",
            "-i", inventory,
            "playbook.yml",
            "-e", f"ip_range={ip_range}",
            "-e", f"wildcard_mask={wildcard_mask}"
        ],
        capture_output=True,
        text=True
    )

    # Capture packets sent after running the playbook
    final_packets_sent = get_packets_sent(interface)
    packets_sent = final_packets_sent - initial_packets_sent

    end_time = time.time()
    duration = end_time - start_time

    return duration, packets_sent

# Main function to run the playbook 10 times with different configurations
def main():
    interface = "ens33"
    inventory = "hosts.ini"

    results = []

    for i in range(10):
        ip_range, wildcard_mask = generate_ip_range()
        duration, packets_sent = run_playbook(ip_range, wildcard_mask, interface, inventory)
        results.append({
            "run": i + 1,
            "ip_range": ip_range,
            "wildcard_mask": wildcard_mask,
            "duration": duration,
            "network_packets_sent": packets_sent
        })
        print(f"Run {i+1}: Duration={duration:.2f}s, Network Packets Sent={packets_sent}")

    # Save the results to a JSON file
    with open("results.json", "w") as f:
        json.dump(results, f, indent=4)

if __name__ == "__main__":
    main()
