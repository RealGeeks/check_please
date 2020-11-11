require_relative 'cli/flag'
# require_relative 'cli/flags'
require_relative 'cli/parser'
require_relative 'cli/runner'

module CheckPlease

  module CLI
    def self.run(exe_file_name)
      Runner.new(__FILE__).run
    end

    FLAGS = []

    def self.flag(&block)
      flag = Flag.new(&block)
      FLAGS << flag
    end

    flag do |f|
      f.short = "-f FORMAT"
      f.long  = "--format FORMAT"
      f.desc  = "format in which to present diffs (available options: [#{CheckPlease::Printers::FORMATS.join(", ")}])"
      f.set_key :format, :to_sym
    end
  end

end
