# change_config.pp
plan bolt_project::change_config(
  TargetSpec $targets
) {
  $cmds = ['show running-config']
  $acl_lines = [
    'ip access-list standard TEST_ACL',
    'permit 192.168.0.0 0.0.255.255'
  ]

  $targets.each |$target| {
    $result = run_command($cmds, $target)
    $running_config = $result[0]['stdout']
    
    if !($running_config =~ /ip access-list standard TEST_ACL/ and $running_config =~ /permit 192.168.0.0 0.0.255.255/) {
      run_command($acl_lines, $target)
    } else {
      out::message("Configuration already present on ${target.uri}")
    }
  }
}
