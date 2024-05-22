import subprocess
import time
import json
import random
import re

def generate_ip_range():
    ip_base = f"192.168.{random.randint(0, 255)}.0"
    wildcard_mask = "0.0.255.255"
    acl_name = f"TEST_ACL_{random.randint(1, 1000)}"
    return ip_base, wildcard_mask, acl_name

def run_bolt_plan(ip_range, wildcard_mask, acl_name, inventory):
    start_time = time.time()
    result = subprocess.run(
        [
            "bolt", "plan", "run", "bolt_module::change_config",
            f"ip_range={ip_range}",
            f"wildcard_mask={wildcard_mask}",
            f"acl_name={acl_name}",
            "--targets", "all",
            "--inventoryfile", inventory
        ],
        capture_output=True,
        text=True
    )
    print(result.stdout)
    print(result.stderr)
    
    packet_count = 0
    match = re.search(r"Number of packets\s+:\s+(\d+)", result.stdout)
    if match:
        packet_count = int(match.group(1))
    
    end_time = time.time()
    duration = end_time - start_time
    return duration, packet_count

def main():
    inventory = "inventory.yaml"
    connectivity_check = subprocess.run(
        ["bolt", "command", "run", "echo 'Connectivity check'", "--targets", "all", "--inventoryfile", inventory],
        capture_output=True,
        text=True
    )
    print("Connectivity check result:")
    print(connectivity_check.stdout)
    results = []
    for i in range(10):
        ip_range, wildcard_mask, acl_name = generate_ip_range()
        duration, packets_sent = run_bolt_plan(ip_range, wildcard_mask, acl_name, inventory)
        results.append({
            "run": i + 1,
            "ip_range": ip_range,
            "wildcard_mask": wildcard_mask,
            "acl_name": acl_name,
            "duration": duration,
            "network_packets_sent": packets_sent
        })
        print(f"Run {i+1}: Duration={duration:.2f}s, Network Packets Sent={packets_sent}")
    with open("results.json", "w") as f:
        json.dump(results, f, indent=4)

if __name__ == "__main__":
    main()
