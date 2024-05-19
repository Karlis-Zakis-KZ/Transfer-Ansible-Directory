# bolt_project/plans/change_config.pp
plan bolt_project::change_config(
  TargetSpec $targets
) {
  $cmd = 'show running-config'
  $acl_lines = [
    'ip access-list standard TEST_ACL',
    'permit 192.168.0.0 0.0.255.255'
  ]

  $targets.each |$target| {
    out::message("Running command on ${target.uri}")
    $result = run_command($cmd, $target)
    if $result.error {
      fail_plan("Failed to run command on ${target.uri}: ${result.error.message}")
    }
    $running_config = $result[0]['stdout']

    if !($running_config =~ /ip access-list standard TEST_ACL/ and $running_config =~ /permit 192.168.0.0 0.0.255.255/) {
      $acl_lines.each |$line| {
        out::message("Applying ACL on ${target.uri}: ${line}")
        $acl_result = run_command($line, $target)
        if $acl_result.error {
          fail_plan("Failed to apply ACL on ${target.uri}: ${acl_result.error.message}")
        }
      }
    } else {
      out::message("Configuration already present on ${target.uri}")
    }
  }
}
