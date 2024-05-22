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

    # Run the ACL command on the target machine
    run_command("enable", $target)
    run_command("configure terminal", $target)

    $acl_output = run_command($acl_command, $target)
    if $acl_output['exit_code'] != 0 {
      fail("Error applying ACL command on ${target}: ${acl_output['stderr']}")
    }
    out::message("ACL command output: ${acl_output}")

    $permit_output = run_command($acl_command_permit, $target)
    if $permit_output['exit_code'] != 0 {
      fail("Error applying permit command on ${target}: ${permit_output['stderr']}")
    }
    out::message("Permit command output: ${permit_output}")

    # Exit configuration mode
    run_command("end", $target)

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
