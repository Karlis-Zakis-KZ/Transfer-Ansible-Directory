# modules/bolt_module/plans/change_config.pp
plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Prepare the ACL configuration command
  $acl_command = "access-list ${acl_name} permit ip ${ip_range} ${wildcard_mask}"

  # Convert TargetSpec to a list of targets
  $target_list = get_targets($targets)

  # Apply the ACL configuration on the routers
  $target_list.each |$target| {
    # Get the target's host
    $target_host = $target['host']

    # Debug message
    out::message("Applying ACL command to ${target_host}")

    # Apply the ACL command directly
    $command = "echo '${acl_command}' | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null karlis@${target_host} 'configure terminal'"
    out::message("Running command: ${command}")

    run_command($command, $target, '_run_as' => 'root')
  }

  # Verify the ACL configuration on the routers
  $acl_verification = $target_list.map |$target| {
    # Get the target's host
    $target_host = $target['host']

    # Debug message
    out::message("Verifying ACL on ${target_host}")

    $output = run_command("ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null karlis@${target_host} 'show access-lists ${acl_name}'", $target, '_run_as' => 'root')
    $output['stdout']
  }

  $acl_verification_str = $acl_verification.join("\n")
  out::message("ACL Configuration:\n${acl_verification_str}")

  # Output ACL verification results
  out::message("ACL Configuration:")
  $acl_verification.each |$verification| {
    out::message($verification)
  }
}
