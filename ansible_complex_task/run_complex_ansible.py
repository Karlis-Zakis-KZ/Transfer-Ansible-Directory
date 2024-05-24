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
    print("capinfos output:")
    print(result.stdout)
    match = re.search(r"Number of packets\s+:\s+(\d+)", result.stdout)
    if match:
        return int(match.group(1))
    return 0

def run_playbook(ip_range, wildcard_mask, acl_name, interface, inventory):
    start_time = time.time()
    tcpdump_process, pcap_file = start_tcpdump(interface)
    result = subprocess.run(
        [
            "ansible-playbook",
            "-i", inventory,
            "complex_playbook.yml",
            "-e", f"ip_range={ip_range}",
            "-e", f"wildcard_mask={wildcard_mask}",
            "-e", f"acl_name={acl_name}"
        ],
        stdout=subprocess.DEVNULL,  # Redirect stdout to /dev/null
        stderr=subprocess.DEVNULL   # Redirect stderr to /dev/null
    )
    stop_tcpdump(tcpdump_process)
    packets_sent = count_packets(pcap_file)
    end_time = time.time()
    duration = end_time - start_time
    return duration, packets_sent

def main():
    interface = "ens33"
    inventory = "hosts.ini"
    connectivity_check = subprocess.run(
        ["ansible", "-i", inventory, "all", "-m", "ping"],
        capture_output=True,
        text=True
    )
    print("Connectivity check result:")
    print(connectivity_check.stdout)
    results = []
    for i in range(10):
        ip_range, wildcard_mask, acl_name = generate_ip_range()
        duration, packets_sent = run_playbook(ip_range, wildcard_mask, acl_name, interface, inventory)
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
