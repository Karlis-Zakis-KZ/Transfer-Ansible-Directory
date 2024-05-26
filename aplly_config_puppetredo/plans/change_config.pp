# aplly_config_puppetredo/plans/change_config.pp
plan aplly_config_puppetredo::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Debugging: Output the inputs
  out::message("Running plan for IP range: ${ip_range}, Wildcard mask: ${wildcard_mask}, ACL name: ${acl_name}")

  # Gather current running config
  $running_config = run_task('aplly_config_puppetredo::command', $targets, { 'command' => 'show running-config' })
  out::message("Running config: ${running_config}")

  # Extract the running config output
  $configs = $running_config.map |$result| {
    $result['result']['stdout']
  }

  # Debugging: Output the extracted configs
  out::message("Configs: ${configs}")

  # Ensure ACL configuration is present
  $targets.each |$target, $index| {
    $config = $configs[$index]
    out::message("Processing target: ${target.uri} with config: ${config}")

    $acl_present = $config =~ /ip access-list standard ${acl_name}/ and $config =~ /permit ${ip_range} ${wildcard_mask}/
    
    if ! $acl_present {
      out::message("ACL not present, applying config on target: ${target.uri}")
      run_task('aplly_config_puppetredo::config', $target, {
        'config' => "ip access-list standard ${acl_name}\n permit ${ip_range} ${wildcard_mask}"
      })
    } else {
      out::message("ACL already present on target: ${target.uri}")
    }
  }

  return { 'message' => 'ACL configuration applied or verified.' }
}
