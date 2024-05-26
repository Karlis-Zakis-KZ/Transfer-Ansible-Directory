# aplly_config_puppetredo/plans/change_config.pp
plan aplly_config_puppetredo::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Gather current running config
  $running_config = run_task('cisco_ios::command', $targets, { 'command' => 'show running-config' })
  
  # Extract the running config output
  $configs = $running_config.result.map |$result| {
    $result['stdout']
  }

  # Ensure ACL configuration is present
  $targets.each |$target, $index| {
    $config = $configs[$index]
    $acl_present = $config =~ /ip access-list standard ${acl_name}/ and $config =~ /permit ${ip_range} ${wildcard_mask}/
    
    if ! $acl_present {
      run_task('cisco_ios::config', $target, {
        'config' => "ip access-list standard ${acl_name}\n permit ${ip_range} ${wildcard_mask}"
      })
    }
  }

  return { 'message' => 'ACL configuration applied or verified.' }
}
