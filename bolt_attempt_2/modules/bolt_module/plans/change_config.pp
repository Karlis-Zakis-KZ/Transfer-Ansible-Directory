plan bolt_module::change_config(
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  $acl_command = "ip access-list extended ${acl_name}"
  $acl_command_permit = "permit ip any ${ip_range} ${wildcard_mask}"

  out::message("Target string: ${targets}")

  # Prepare the targets for applying Puppet resources
  apply_prep($targets)

  # Define the configuration manifest
  $manifest = @("END")
    ios_config { 'Set ACL':
      command => "${acl_command}
      ${acl_command_permit}"
    }
END

  # Apply the manifest to the targets
  $apply_results = apply($targets, _catch_errors => true)
  
  # Handle the results of the apply
  $apply_results.each |$apply_result| {
    if $apply_result['status'] == 'failed' {
      fail("Failed to apply manifest to ${apply_result['target']}: ${apply_result['result']['_error']['msg']}")
    } else {
      out::message("Successfully applied manifest to ${apply_result['target']}")
    }
  }

  out::message("Verifying ACL on targets")

  # Verify the ACL configuration
  $targets.each |$target| {
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
