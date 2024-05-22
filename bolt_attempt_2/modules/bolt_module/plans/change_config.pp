plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  $acl_command = "access-list ${acl_name} permit ip ${ip_range} ${wildcard_mask}"

  $targets.each |$target| {
    out::message("Applying ACL command to ${target.uri}")

    # Run the ACL command on the target machine
    run_command("configure terminal", $target, '_run_as' => 'root')
    run_command($acl_command, $target, '_run_as' => 'root')
    run_command("exit", $target, '_run_as' => 'root')

    out::message("Verifying ACL on ${target.uri}")

    $output = run_command("show access-lists ${acl_name}", $target, '_run_as' => 'root')
    out::message($output['stdout'])
  }
}
