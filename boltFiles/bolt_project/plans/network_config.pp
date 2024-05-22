# plans/network_config.pp
plan bolt_project::network_config(
  TargetSpec $targets,
  String $interface,
  Integer $runs
) {
  $results = run_task('bolt_project::network_config_task', $targets, {
    interface => $interface,
    runs      => $runs,
  })

  # Output the results
  out::message("Results of running network configuration task:")
  out::message($results)
}
