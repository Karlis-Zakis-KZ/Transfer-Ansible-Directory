plan manage_network::manage_network(
  TargetSpec $targets,
  String $interface,
) {
  # Generate IP ranges and ACL names
  $ip_range = '192.168.100.0'
  $wildcard_mask = '0.0.255.255'
  $acl_name = 'TEST_ACL_100'

  # Run configure network task
  run_task('manage_network::configure_network', $targets, ip_range => $ip_range, wildcard_mask => $wildcard_mask, acl_name => $acl_name)

  # Start tcpdump
  $tcpdump_result = run_command("sudo tcpdump -i ${interface} -w /tmp/tcpdump_output.pcap", $targets)

  # Sleep for some time to capture traffic
  run_command('sleep 60', $targets)

  # Stop tcpdump
  run_command('sudo pkill tcpdump', $targets)

  # Analyze captured traffic
  $capinfos_result = run_command("capinfos /tmp/tcpdump_output.pcap", $targets)

  # Run revert network task
  run_task('manage_network::revert_network', $targets, acl_name => $acl_name)

  return {
    configure => $tcpdump_result,
    analyze => $capinfos_result,
  }
}
