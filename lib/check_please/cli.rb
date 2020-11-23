module CheckPlease

  module CLI
    autoload :Runner, "check_please/cli/parser"
    autoload :Parser, "check_please/cli/runner"

    def self.run(exe_file_name)
      Runner.new(__FILE__).run(*ARGV.dup)
    end
  end

end
