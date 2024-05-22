import sys
import subprocess
import re
from netmiko import ConnectHandler

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

def configure_device(device, interface, runs):
    try:
        connection = ConnectHandler(**device)
        for i in range(1, runs + 1):
            commands = [
                "interface GigabitEthernet0/1",  # Change this to the appropriate interface on your router
                f"description Configured by Netmiko run {i}"
            ]
            output = connection.send_config_set(commands)
            print(f"Run {i} output:\n{output}")
        connection.disconnect()
    except Exception as e:
        print(f"Failed to configure device {device['host']}: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: network_config_with_capture.py <interface> <runs> <hosts_file>")
        sys.exit(1)

    interface = sys.argv[1]
    runs = int(sys.argv[2])
    hosts_file = sys.argv[3]

    process, pcap_file = start_tcpdump(interface)

    with open(hosts_file, 'r') as f:
        hosts = f.readlines()

    for host in hosts:
        device = {
            'device_type': 'cisco_ios',
            'host': host.strip(),
            'username': 'karlis',
            'password': 'cisco',
        }
        configure_device(device, interface, runs)

    stop_tcpdump(process)
    packets_count = count_packets(pcap_file)
    print(f"Total packets captured: {packets_count}")
