# plans/network_config.pp
plan my_project::network_config(
  TargetSpec $targets,
  String $interface = 'ens33',
  Integer $runs = 10
) {
  $results = []

  # Connectivity check
  $connectivity = run_command('ping -c 1 8.8.8.8', $targets)
  out::message("Connectivity check result: ${connectivity}")

  # Loop for multiple runs
  for $i in Range[1, $runs] {
    $ip_range = sprintf('192.168.%d.0', Random[0, 255].next())
    $wildcard_mask = '0.0.255.255'
    $acl_name = sprintf('TEST_ACL_%d', Random[1, 1000].next())
    $pcap_file = sprintf('tcpdump_output_%d.pcap', $i)

    # Start tcpdump
    run_command("sudo tcpdump -i ${interface} -w ${pcap_file} &", $targets)

    # Apply configuration
    run_command("puppet device --target ${targets} --apply '/path/to/manifest.pp' --debug", $targets, _catch_errors => true)

    # Stop tcpdump
    run_command("sudo pkill -SIGINT tcpdump", $targets)

    # Analyze pcap file
    $capinfos_output = run_command("capinfos ${pcap_file}", $targets)
    out::message("capinfos output for run ${i}: ${capinfos_output}")

    # Extracting data from capinfos output
    $packets = regsubst($capinfos_output['stdout'], '.*Number of packets\s+:\s+(\d+).*', '\1', 'G')
    $duration = regsubst($capinfos_output['stdout'], '.*Capture duration\s+:\s+([\d\.]+).*', '\1', 'G')

    $results += {
      run    => $i,
      ip_range => $ip_range,
      wildcard_mask => $wildcard_mask,
      acl_name => $acl_name,
      packets => $packets,
      duration => $duration
    }
  }

  # Write results to a file
  file::write('/tmp/results.json', to_json($results))

  return $results
}
