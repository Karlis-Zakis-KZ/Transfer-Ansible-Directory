plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  $acl_command = "ip access-list extended ${acl_name}"
  $acl_command_permit = "permit ip any ${ip_range} ${wildcard_mask}"

  out::message("Target string: ${targets}")

  $target_array = $targets.split(',')

  $target_array.each |$target| {
    out::message("Applying ACL command to ${target}")

    # Define command execution with error handling
    $commands = [
      "enable",
      "configure terminal",
      $acl_command,
      $acl_command_permit,
      "end"
    ]

    $commands.each |$cmd| {
      $result = run_command($cmd, $target)
      if $result['exit_code'] != 0 {
        fail("Error running command '${cmd}' on ${target}: ${result['stderr']}")
      }
      out::message("Command '${cmd}' output: ${result['stdout']}")
    }

    # Verify the ACL
    out::message("Verifying ACL on ${target}")
    $output = run_command("show access-lists ${acl_name}", $target)

    if $output['exit_code'] == 0 {
      $stdout = $output['stdout']
      out::message($stdout)
    } else {
      $stderr = $output['stderr']
      fail("Error verifying ACL on ${target}: ${stderr}")
    }
  }
}
