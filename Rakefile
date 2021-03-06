require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "pathname"
require "tempfile"


PROJECT_ROOT = Pathname.new(File.dirname(__FILE__))


namespace :spec do
  desc "All tests *except* those that exercise the executable CLI"
  RSpec::Core::RakeTask.new(:not_cli) do |t|
    t.rspec_opts = "--tag ~cli"
  end

  desc "fast tests only"
  task fast: :not_cli

  # These are much slower than the rest, since they use Kernel#`
  desc "Only tests that exercise the executable CLI (slower)"
  RSpec::Core::RakeTask.new(:cli) do |t|
    t.rspec_opts = "--tag cli"
  end

  desc "approve changes to the CLI's `--help` output"
  task :approve_cli_help_output do
    output = `exe/check_please`
    File.open(PROJECT_ROOT.join("spec/fixtures/cli-help-output"), "w") do |f|
      f << output
    end
  end
end

# By default, `rake spec` should run fast specs first, then cli if those all pass
desc "Run all tests (fast tests first, then the slower CLI ones)"
task :spec => [ "spec:fast", "spec:cli" ]

task :default => :spec




desc "Generate TOC for the README"
task :toc do
  # the `--no-backup` flag skips the creation of README.md.* backup files,
  # WHICH IS FINE because we're using Git
  puts "generating TOC..."
  `bin/gh-md-toc --no-backup README.md`

  # Now, strip out the 'Added by:` line so we can detect if there were actual changes
  # Use a tempfile just in case sed barfs, I guess?
  tmp = Tempfile.new('check-please-readme')
  begin
    `sed '/Added by: /d' README.md > #{tmp.path}`
    FileUtils.mv tmp.path, PROJECT_ROOT.join("README.md")
  ensure
    tmp.close
    tmp.unlink
  end
end

# Okay, so.  We want the TOC to be up to date *before* the `release` task runs.
#
# We tried making the 'toc' task a dependency of 'release', but that just adds
# it to the end of the dependencies, and generates the TOC after publishing.
#
# Trying the 'build' task instead...
task :build => :toc
