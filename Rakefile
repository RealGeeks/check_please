require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "pathname"
require "tempfile"

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
end

# By default, `rake spec` should run fast specs first, then cli if those all pass
desc "Run all tests (fast tests first, then the slower CLI ones)"
task :spec => [ "spec:fast", "spec:cli" ]

task :default => :spec



PROJECT_ROOT = Pathname.new(File.dirname(__FILE__))

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

# By making TOC generation a prerequisite of release, we *should* at least be
# forced to update the TOC whenever we publish a new version of the gem...
task :release => :toc
