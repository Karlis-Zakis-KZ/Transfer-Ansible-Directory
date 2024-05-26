plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Define the ACL commands
  $acl_command = "ip access-list extended ${acl_name}"
  $acl_command_permit = "permit ip any ${ip_range} ${wildcard_mask}"

  out::message("Target string: ${targets}")

  # Convert the TargetSpec to an array of Target objects
  $target_objects = get_targets($targets)

  # Print the target objects for debugging
  out::message("Target objects: ${target_objects}")

  # Prepare the targets for applying Puppet resources
  apply_prep($targets)

  # Apply the ACL commands to the targets
  $target_objects.each |$target| {
    out::message("Applying ACL commands to target: ${target}")

    $result_acl_command = run_command($acl_command, $target)
    if !$result_acl_command.ok {
      fail("Failed to run ACL command '${acl_command}' on target ${target}: ${result_acl_command['stderr']}")
    }

    $result_acl_permit = run_command($acl_command_permit, $target)
    if (!$result_acl_permit.ok) {
      fail("Failed to run ACL permit command '${acl_command_permit}' on target ${target}: ${result_acl_permit['stderr']}")
    }
  }

  out::message("Verifying ACL on targets")

  # Verify the ACL configuration
  $target_objects.each |$target| {
    $output = run_task('cisco_ios::command', $target, {'command' => "show access-lists ${acl_name}"})
    
    if $output.ok {
      $stdout = $output.result['stdout']
      out::message($stdout)
    } else {
      $stderr = $output.result['stderr']
      fail("Error verifying ACL on ${target}: ${stderr}")
    }
  }
}
