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
    run_command("enable", $target, '_run_as' => 'karlis', 'password' => 'cisco')
    run_command("configure terminal", $target, '_run_as' => 'karlis', 'password' => 'cisco')
    $whatResutns = run_command($acl_command, $target, '_run_as' => 'karlis', 'password' => 'cisco')
    out::message($whatResutns)
    run_command($acl_command_permit, $target, '_run_as' => 'karlis', 'password' => 'cisco')
    run_command("end", $target, '_run_as' => 'karlis', 'password' => 'cisco')

    out::message("Verifying ACL on ${target}")

    $output = run_command("show access-lists ${acl_name}", $target, '_run_as' => 'karlis', 'password' => 'cisco')
    
    if $output['exit_code'] == 0 {
      $stdout = $output['stdout']
      out::message($stdout)
    } else {
      $stderr = $output['stderr']
      fail("Error verifying ACL on ${target}: ${stderr}")
    }
  }
}
