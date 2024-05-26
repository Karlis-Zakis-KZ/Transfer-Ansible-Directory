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

  # Function to check if ACL already exists on the target
  function check_acl {
    $target = $1
    $acl_name = $2
    $ip_range = $3
    $wildcard_mask = $4
    $check_command = "show running-config | include ip access-list extended ${acl_name}"
    $check_result = run_command($check_command, $target)

    if $check_result.ok {
      $running_config = $check_result.result['stdout']
      return $running_config.any |$line| { 
        $line =~ /ip access-list extended ${acl_name}/ and $line =~ /permit ip any ${ip_range} ${wildcard_mask}/
      }
    } else {
      fail("Failed to check ACL on target ${target}: ${check_result['stderr']}")
    }
  }

  # Apply the ACL commands to the targets
  $target_objects.each |$target| {
    if !check_acl($target, $acl_name, $ip_range, $wildcard_mask) {
      out::message("Applying ACL commands to target: ${target}")

      $commands = [
        $acl_command,
        $acl_command_permit,
      ]

      $commands.each |$command| {
        $result = run_command($command, $target)
        if !$result.ok {
          fail("Failed to run command '${command}' on target ${target}: ${result['stderr']}")
        }
      }
    } else {
      out::message("ACL already configured on target: ${target}")
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
