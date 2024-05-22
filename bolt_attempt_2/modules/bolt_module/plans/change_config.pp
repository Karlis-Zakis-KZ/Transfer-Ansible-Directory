# modules/bolt_module/plans/change_config.pp
plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Start tcpdump
  $tcpdump_result = run_command('sudo tcpdump -i ens33 -w /tmp/tcpdump_output.pcap', $targets, '_run_as' => 'root')
  
  # Execute the configuration change
  run_command("echo 'Configuring ACL with range ${ip_range} and mask ${wildcard_mask}'", $targets)
  
  # Stop tcpdump
  run_command('sudo pkill -f tcpdump', $targets, '_run_as' => 'root')

  # Analyze the pcap file to count packets
  $packet_count = run_command('capinfos /tmp/tcpdump_output.pcap | grep "Number of packets"', $targets)
  
  return $packet_count
}
