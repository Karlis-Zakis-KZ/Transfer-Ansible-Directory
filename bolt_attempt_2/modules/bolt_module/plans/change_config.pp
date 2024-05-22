# modules/bolt_module/plans/change_config.pp
plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Start tcpdump
  $tcpdump_result = run_command('sudo tcpdump -i ens33 -w /tmp/tcpdump_output.pcap', $targets, '_run_as' => 'root')

  # Prepare the ACL configuration command
  $acl_command = "access-list ${acl_name} permit ip ${ip_range} ${wildcard_mask}"

  # Apply the ACL configuration on the routers
  $targets.each |$target| {
    run_command("echo '${acl_command}' > /tmp/acl_config.txt", $target)
    run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@${target.uri} 'configure terminal < /tmp/acl_config.txt'", $target)
  }

  # Stop tcpdump
  run_command('sudo pkill -f tcpdump', $targets, '_run_as' => 'root')

  # Analyze the pcap file to count packets
  $packet_count = run_command('capinfos /tmp/tcpdump_output.pcap | grep "Number of packets"', $targets)

  # Verify the ACL configuration on the routers
  $acl_verification = $targets.map |$target| {
    $output = run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@${target.uri} 'show access-lists ${acl_name}'", $target)
    $output['stdout']
  }
  out::message("ACL Configuration:\n${acl_verification.join('\n')}")

  # Return packet count and ACL verification results
  return {
    'packet_count'  => $packet_count,
    'acl_verification' => $acl_verification.join('\n')
  }
}
