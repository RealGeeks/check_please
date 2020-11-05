require "bundler/setup"
require "check_please"



require 'pathname'
PROJECT_ROOT = Pathname.new(
  File.expand_path(
    File.join( File.dirname(__FILE__), '..' )
  )
)
Dir[ PROJECT_ROOT.join('spec', 'support', '**', '*.rb') ].each { |f| require f }



RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |c|
    c.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
  config.order = :random
  Kernel.srand config.seed
end



# Always clear the global that Sam has a tendency to set
RSpec.configure do |config|
  config.after(:each) do
    $debug = false
  end
end

