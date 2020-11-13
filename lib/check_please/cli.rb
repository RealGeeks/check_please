require_relative 'cli/flag'
# require_relative 'cli/flags'
require_relative 'cli/parser'
require_relative 'cli/runner'

module CheckPlease

  module CLI
    def self.run(exe_file_name)
      Runner.new(__FILE__).run(*ARGV.dup)
    end



    FLAGS = []
    def self.flag(*args, &block)
      flag = Flag.new(*args, &block)
      FLAGS << flag
    end

    ##### Define CLI flags here #####

    flag "-f FORMAT", "--format FORMAT" do |f|
      f.desc = "format in which to present diffs (available options: [#{CheckPlease::Printers::FORMATS.join(", ")}])"
      f.set_key :format, :to_sym
    end
  end

end
