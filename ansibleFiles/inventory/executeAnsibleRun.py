import subprocess
import time
import pandas as pd

def run_playbook():
    result = subprocess.run(
        ["ansible-playbook", "your_playbook.yml"],
        capture_output=True,
        text=True
    )
    return result.stdout, result.stderr

def run_tcpdump(interface, duration=10):
    tcpdump_cmd = [
        "sudo", "tcpdump", "-i", interface, "-w", "tcpdump_output.pcap", "-G", str(duration), "-W", "1"
    ]
    subprocess.run(tcpdump_cmd)

def parse_capinfos():
    result = subprocess.run(
        ["capinfos", "tcpdump_output.pcap"],
        capture_output=True,
        text=True
    )
    return result.stdout

def extract_packet_info(capinfos_output):
    lines = capinfos_output.splitlines()
    info = {}
    for line in lines:
        if line.startswith("Number of packets:"):
            info['packets'] = int(line.split(":")[1].strip())
        elif line.startswith("Capture duration:"):
            info['duration'] = float(line.split(":")[1].strip().split()[0])
    return info

def main():
    num_runs = 10
    results = []

    for i in range(num_runs):
        print(f"Run {i+1}:")
        # Start tcpdump
        run_tcpdump(interface="eth0", duration=10)
        
        # Run the playbook
        stdout, stderr = run_playbook()
        print("Playbook output:")
        print(stdout)
        if stderr:
            print("Errors:")
            print(stderr)
        
        # Parse tcpdump output
        capinfos_output = parse_capinfos()
        packet_info = extract_packet_info(capinfos_output)
        
        results.append({
            "run": i+1,
            "duration": packet_info.get('duration', 0),
            "packets": packet_info.get('packets', 0)
        })
        
        print(f"Run {i+1}: Duration={packet_info.get('duration', 0)}s, Packets={packet_info.get('packets', 0)}")
        time.sleep(1)  # Optional: Add delay between runs

    df = pd.DataFrame(results)
    df.to_csv("results.csv", index=False)
    print("Results saved to results.csv")

if __name__ == "__main__":
    main()
