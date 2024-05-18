plan change_config(
  TargetSpec $targets
) {
  $config_command = @("END"
    ip access-list standard TEST_ACL
    permit 192.168.0.0 0.0.255.255
  END

  $targets.each |$target| {
    run_command($config_command, $target)
  }
}