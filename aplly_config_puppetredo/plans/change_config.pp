# aplly_config_puppetredo/plans/change_config.pp
plan aplly_config_puppetredo::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Print the inventory for debugging
  out::message("Inventory: ${get_targets($targets)}")

  # Run the command to gather the current running config
  $result_set = run_task('aplly_config_puppetredo::command', $targets, { 'command' => 'show running-config' })
  
  if $result_set.ok {
    # Convert the TargetSpec to an array of Target objects
    $target_objects = get_targets($targets)

    # Print the target objects for debugging
    out::message("Target objects: ${target_objects}")

    # Directly iterate over the target objects and their results
    $target_objects.each |$target, $index| {
      $result = $result_set[$index]
      $config = $result['result']['stdout']
      
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
  } else {
    out::message("Failed to gather running config. Command failed on some targets.")
  }
}
