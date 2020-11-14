require "bundler/gem_tasks"
require "rspec/core/rake_task"

namespace :spec do
  RSpec::Core::RakeTask.new(:all)

  RSpec::Core::RakeTask.new(:not_cli) do |t|
    t.rspec_opts = "--tag ~cli"
  end
  task fast: :not_cli

  # These are much slower than the rest, since they use Kernel#`
  RSpec::Core::RakeTask.new(:cli) do |t|
    t.rspec_opts = "--tag cli"
  end
end

# By default, `rake spec` should run fast specs first, then cli if those all pass
task :spec => [ "spec:not_cli", "spec:cli" ]

task :default => :spec
