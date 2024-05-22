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

    # Run the enable command on the target machine
    $enable_output = run_command("enable", $target)
    if $enable_output['exit_code'] != 0 {
      fail("Error running enable on ${target}: ${enable_output['stderr']}")
    }

    # Run the configure terminal command
    $configure_output = run_command("configure terminal", $target)
    if $configure_output['exit_code'] != 0 {
      fail("Error running configure terminal on ${target}: ${configure_output['stderr']}")
    }

    # Apply the ACL command
    $acl_output = run_command($acl_command, $target)
    if $acl_output['exit_code'] != 0 {
      fail("Error applying ACL command on ${target}: ${acl_output['stderr']}")
    }
    out::message("ACL command output: ${acl_output['stdout']}")

    # Apply the permit command within the ACL context
    $permit_output = run_command($acl_command_permit, $target)
    if $permit_output['exit_code'] != 0 {
      fail("Error applying permit command on ${target}: ${permit_output['stderr']}")
    }
    out::message("Permit command output: ${permit_output['stdout']}")

    # Exit configuration mode
    $end_output = run_command("end", $target)
    if $end_output['exit_code'] != 0 {
      fail("Error running end on ${target}: ${end_output['stderr']}")
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
