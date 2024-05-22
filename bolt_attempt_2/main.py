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

def start_tcpdump(interface="ens33", file_prefix="tcpdump_output"):
    pcap_file = f"{file_prefix}.pcap"
    process = subprocess.Popen(
        ["sudo", "tcpdump", "-i", interface, "-w", pcap_file],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
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
    
    acl_verification = ""
    acl_match = re.search(r"ACL Configuration:\n(.*)", result.stdout, re.DOTALL)
    if acl_match:
        acl_verification = acl_match.group(1)
    
    return acl_verification

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
    results = []
    for i in range(10):
        ip_range, wildcard_mask, acl_name = generate_ip_range()
        
        # Start tcpdump
        tcpdump_process, pcap_file = start_tcpdump(interface)
        
        # Run the Bolt plan
        start_time = time.time()
        acl_verification = run_bolt_plan(ip_range, wildcard_mask, acl_name, inventory)
        end_time = time.time()
        
        # Stop tcpdump
        stop_tcpdump(tcpdump_process)
        
        # Count packets
        packets_sent = count_packets(pcap_file)
        
        duration = end_time - start_time
        results.append({
            "run": i + 1,
            "ip_range": ip_range,
            "wildcard_mask": wildcard_mask,
            "acl_name": acl_name,
            "duration": duration,
            "network_packets_sent": packets_sent,
            "acl_verification": acl_verification
        })
        print(f"Run {i+1}: Duration={duration:.2f}s, Network Packets Sent={packets_sent}, ACL Verification:\n{acl_verification}")
    
    with open("results.json", "w") as f:
        json.dump(results, f, indent=4)

if __name__ == "__main__":
    main()
