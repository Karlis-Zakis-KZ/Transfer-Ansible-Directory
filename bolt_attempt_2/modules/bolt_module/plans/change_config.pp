# modules/bolt_module/plans/change_config.pp
plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Start tcpdump
  $tcpdump_result = run_command('sudo tcpdump -i ens33 -w /tmp/tcpdump_output.pcap', $targets, '_run_as' => 'root')
  
  # Apply the ACL configuration on the routers
  run_command("echo 'access-list ${acl_name} permit ip ${ip_range} ${wildcard_mask}' > /tmp/acl_config.txt", $targets)
  run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@192.168.21.11 'configure terminal' < /tmp/acl_config.txt", $targets)
  run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@192.168.21.12 'configure terminal' < /tmp/acl_config.txt", $targets)
  run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@192.168.21.13 'configure terminal' < /tmp/acl_config.txt", $targets)
  run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@192.168.21.14 'configure terminal' < /tmp/acl_config.txt", $targets)

  # Stop tcpdump
  run_command('sudo pkill -f tcpdump', $targets, '_run_as' => 'root')

  # Analyze the pcap file to count packets
  $packet_count = run_command('capinfos /tmp/tcpdump_output.pcap | grep "Number of packets"', $targets)
  
  # Verify the ACL configuration on the routers
  $acl_verification = run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@192.168.21.11 'show access-lists ${acl_name}'", $targets)
  out::message("ACL Configuration:\n${acl_verification}")

  # Return packet count and ACL verification results
  return {
    'packet_count'  => $packet_count,
    'acl_verification' => $acl_verification
  }
}
