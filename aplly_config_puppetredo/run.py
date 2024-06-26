import subprocess
import time
import json
import random
import re
import os

def generate_ip_range():
    ip_base = f"192.168.{random.randint(0, 255)}.0"
    wildcard_mask = "0.0.255.255"
    acl_name = f"TEST_ACL_{random.randint(1, 1000)}"
    return ip_base, wildcard_mask, acl_name

def start_tcpdump(interface="ens33", file_prefix="tcpdump_output"):
    pcap_file = f"{file_prefix}.pcap"
    process = subprocess.Popen(
        ["sudo", "tcpdump", "-i", interface, "-w", pcap_file],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    time.sleep(1)  # Add a delay to give tcpdump time to start
    if process.poll() is not None:
        print(f"Failed to start tcpdump: {process.stderr.read().decode()}")
    return process, pcap_file

def stop_tcpdump(process):
    process.terminate()
    process.wait()

def count_packets(pcap_file):
    result = subprocess.run(
        ["capinfos", pcap_file],
        capture_output=True,
        text=True
    )
    match = re.search(r"Number of packets\s+:\s+(\d+)", result.stdout)
    if match:
        return int(match.group(1))
    return 0

def run_bolt_plan(ip_range, wildcard_mask, acl_name, inventory):
    result = subprocess.run(
        [
            "bolt", "plan", "run", "aplly_config_puppetredo::apply_config_change",
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
    
    return result.stdout

def main():
    interface = "ens33"
    inventory = "inventory.yaml"
    connectivity_check = subprocess.run(
        ["bolt", "command", "run", "echo 'Connectivity check'", "--targets", "all", "--inventoryfile", inventory],
        capture_output=True,
        text=True
    )
    print("Connectivity check result:")
    print(connectivity_check.stdout)
    
    if connectivity_check.returncode != 0:
        print("Failed to establish connectivity with targets.")
        return
    
    results = []
    for i in range(10):
        ip_range, wildcard_mask, acl_name = generate_ip_range()
        
        # Start tcpdump
        tcpdump_process, pcap_file = start_tcpdump(interface)
        time.sleep(1)  # Add a short delay

        try:
            # Run the Bolt plan
            acl_verification = run_bolt_plan(ip_range, wildcard_mask, acl_name, inventory)
        finally:
            # Stop tcpdump
            stop_tcpdump(tcpdump_process)

        # Count packets
        packets_sent = count_packets(pcap_file)

        # Append results
        results.append({
            "run": i + 1,
            "ip_range": ip_range,
            "wildcard_mask": wildcard_mask,
            "acl_name": acl_name,
            "acl_verification": acl_verification,
            "network_packets_sent": packets_sent
        })
        print(f"Run {i+1}: ACL Verification={acl_verification}, Network Packets Sent={packets_sent}")
        
        # Clean up pcap file
        if os.path.exists(pcap_file):
            os.remove(pcap_file)
    
    with open("results.json", "w") as f:
        json.dump(results, f, indent=4)

if __name__ == "__main__":
    main()
