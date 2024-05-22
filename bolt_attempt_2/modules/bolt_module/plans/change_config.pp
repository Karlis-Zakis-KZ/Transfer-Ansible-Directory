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
    $commands = [
      "configure terminal",
      $acl_command,
      "end",
      "write memory"
    ]

    $commands.each |$cmd| {
      $output = run_command($cmd, $target)
      out::message("Output for command '${cmd}': ${$output['stdout']}")
    }

    out::message("Verifying ACL on ${target.uri}")

    $output = run_command("show access-lists ${acl_name}", $target)
    out::message($output['stdout'])
  }
}
