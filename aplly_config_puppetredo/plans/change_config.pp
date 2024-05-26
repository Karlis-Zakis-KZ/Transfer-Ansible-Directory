plan aplly_config_puppetredo::apply_config_change (
  TargetSpec $targets,
  String $ip_range,
  String $wildcard_mask,
  String $acl_name
) {
  $results = run_task('ios_command', $targets, {
    commands => ['show running-config']
  })

  $results.each |$result| {
    $running_config = $result['result']['stdout'][0]

    unless $running_config =~ /ip access-list standard ${acl_name}/ and $running_config =~ /permit ${ip_range} ${wildcard_mask}/ {
      run_task('ios_config', $result['target'], {
        lines   => ["permit ${ip_range} ${wildcard_mask}"],
        parents => ["ip access-list standard ${acl_name}"]
      })
    }
  }
}
