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
    run_command("echo '${acl_command}' > /tmp/acl_config.txt", $target)
    run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@${target.uri} 'configure terminal < /tmp/acl_config.txt'", $target)
  }

  # Verify the ACL configuration on the routers
  $acl_verification = $targets.map |$target| {
    $output = run_command("sshpass -p 'cisco' ssh -o StrictHostKeyChecking=no karlis@${target.uri} 'show access-lists ${acl_name}'", $target)
    $output['stdout']
  }
  $acl_verification_str = $acl_verification.join("\n")
  out::message("ACL Configuration:\n${acl_verification_str}")

  # Return ACL verification results
  return {
    'acl_verification': $acl_verification_str
  }
}
