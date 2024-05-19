# bolt_project/plans/enable_shell_and_run_command.pp
plan enable_shell_and_run_command(
  TargetSpec $targets,
  String $command
) {
  # Enable the shell on the target(s)
  run_command('term shell', $targets)

  # Run the specified command
  run_command($command, $targets)
}
