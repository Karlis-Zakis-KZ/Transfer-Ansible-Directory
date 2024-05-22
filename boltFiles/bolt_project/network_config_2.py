import sys
from netmiko import ConnectHandler

def configure_device(device, interface, runs):
    try:
        connection = ConnectHandler(**device)
        for i in range(1, runs + 1):
            commands = [
                f"interface {interface}",
                f"description Configured by Netmiko run {i}"
            ]
            output = connection.send_config_set(commands)
            print(f"Run {i} output:\n{output}")
        connection.disconnect()
    except Exception as e:
        print(f"Failed to configure device {device['host']}: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: network_config.py <interface> <runs> <hosts_file>")
        sys.exit(1)

    interface = sys.argv[1]
    runs = int(sys.argv[2])
    hosts_file = sys.argv[3]

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
