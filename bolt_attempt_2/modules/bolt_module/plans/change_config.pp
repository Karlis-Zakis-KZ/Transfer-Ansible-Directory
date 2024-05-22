# modules/bolt_module/plans/change_config.pp
plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Prepare the ACL configuration command
  $acl_command = "access-list ${acl_name} permit ip ${ip_range} ${wildcard_mask}"

  # Ensure $targets is an array
  $target_array = $targets.split(',')

  # Apply the ACL configuration on the routers
  $target_array.each |$target| {
    # Debug message
    out::message("Applying ACL command to ${target}")

    # Apply the ACL command directly
    $command = "echo '${acl_command}' | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null karlis@${target} 'configure terminal'"
    out::message("Running command: ${command}")

    run_command($command, $target, '_run_as' => 'root')
  }

  # Verify the ACL configuration on the routers
  $acl_verification = $target_array.map |$target| {
    # Debug message
    out::message("Verifying ACL on ${target}")

    $output = run_command("ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null karlis@${target} 'show access-lists ${acl_name}'", $target, '_run_as' => 'root')
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
