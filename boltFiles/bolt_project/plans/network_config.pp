# plans/network_config.pp
plan bolt_project::network_config(
  TargetSpec $targets,
  String $interface,
  Integer $runs = 10,
) {

  # Function to generate random IP range
  function generate_ip_range() {
    $ip_base = "192.168.${Integer.new(rand(256))}.0"
    $wildcard_mask = "0.0.255.255"
    return [$ip_base, $wildcard_mask]
  }

  # Function to generate random ACL name
  function generate_acl_name() {
    $acl_name = "TEST_ACL_${Integer.new(rand(1000))}"
    return $acl_name
  }

  # Ensure connectivity
  $connectivity = run_command('ping -c 1 google.com', $targets)
  out::message("Connectivity check result: ${connectivity}")

  # Collect results for each run
  $results = []

  # Repeat the task for a number of runs
  for $i in Range[1, $runs] {
    $ip_range, $wildcard_mask = generate_ip_range()
    $acl_name = generate_acl_name()

    # Start tcpdump
    $start_tcpdump = run_command("sudo tcpdump -i ${interface} -w tcpdump_output_${i}.pcap", $targets, { '_run_as' => 'root', '_tty' => true })
    run_task('puppet_agent::install', $targets) # Ensure Puppet agent is installed

    # Apply configuration to routers
    $apply_config = apply($targets) {
      network_device::interface { 'acl_config':
        ensure         => 'present',
        acl_name       => $acl_name,
        ip_range       => $ip_range,
        wildcard_mask  => $wildcard_mask,
      }
    }

    # Stop tcpdump
    $stop_tcpdump = run_command("sudo pkill -f 'tcpdump -i ${interface}'", $targets, { '_run_as' => 'root', '_tty' => true })

    # Count packets
    $count_packets = run_command("capinfos -c tcpdump_output_${i}.pcap", $targets)
    out::message("capinfos output for run ${i}: ${count_packets}")

    $results += {
      'run' => $i,
      'ip_range' => $ip_range,
      'wildcard_mask' => $wildcard_mask,
      'acl_name' => $acl_name,
      'packets_count' => $count_packets.stdout,
    }
  }

  return $results
}
