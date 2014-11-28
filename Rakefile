require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

PuppetSyntax.exclude_paths = exclude_paths

# Puppet-Lint 1.1.0
Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|

  # Pattern of files to ignore
  config.ignore_paths = exclude_paths

  # List of checks to disable
  config.disable_checks = ['documentation', '80chars', 'autoloader_layout']

  # Should puppet-lint prefix it's output with the file being checked,
  # defaults to true
  config.with_filename = false

  # Should the task fail if there were any warnings, defaults to false
  config.fail_on_warnings = true

  # Format string for puppet-lint's output (see the puppet-lint help output
  # for details
  config.log_format = '%{path}:%{linenumber}:%{check}:%{KIND}:%{message}'

  # Print out the context for the problem, defaults to false
  config.with_context = true

  # Enable automatic fixing of problems, defaults to false
  config.fix = true

  # Show ignored problems in the output, defaults to false
  config.show_ignored = true
end

task :metadata do
  sh "metadata-json-lint metadata.json"
end

task :default => [:syntax, :lint, :metadata]
