# modules/bolt_module/plans/change_config.pp
plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  # Prepare the ACL configuration command
  $acl_command = "access-list ${acl_name} permit ip ${ip_range} ${wildcard_mask}"

  # Apply the ACL configuration on the routers
  $targets.each |$target| {
    # Write the ACL command to a temporary file on the target
    run_command("echo '${acl_command}' > /tmp/acl_config.txt", $target)
    # Apply the configuration using the temporary file
    run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@${target.uri} 'configure terminal < /tmp/acl_config.txt'", $target)
  }

  # Verify the ACL configuration on the routers
  $acl_verification = $targets.map |$target| {
    $output = run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@${target.uri} 'show access-lists ${acl_name}'", $target)
    $output['stdout']
  }

  # Output ACL verification results
  out::message("ACL Configuration:")
  $acl_verification.each |$verification| {
    out::message($verification)
  }
}
