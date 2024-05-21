# bolt_project/plans/change_config.pp
plan bolt_project::change_config(
  TargetSpec $targets
) {
  $cmds = 'show running-config'
  $acl_lines = "ip access-list standard TEST_ACL\npermit 192.168.0.0 0.0.255.255"

  $targets.each |$target| {
    # Gather current running config
    $result = run_task('cisco_ios::cli_command', $target, { 'command' => $cmds, 'raw' => false })
    $running_config = $result[0]['result']['stdout']

    # Check if the ACL configuration is already present
    if !($running_config =~ /ip access-list standard TEST_ACL/ and $running_config =~ /permit 192.168.0.0 0.0.255.255/) {
      run_task('cisco_ios::cli_command', $target, { 'command' => $acl_lines, 'raw' => false })
    } else {
      out::message("Configuration already present on ${target.uri}")
    }
  }
}
