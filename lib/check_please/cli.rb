module CheckPlease

  module CLI
    autoload :Flag,   "check_please/cli/flag"
    autoload :Runner, "check_please/cli/parser"
    autoload :Parser, "check_please/cli/runner"

    def self.run(exe_file_name)
      Runner.new(__FILE__).run(*ARGV.dup)
    end



    FLAGS = []
    def self.flag(long:, short: nil, &block)
      flag = Flag.new(short, long, &block)
      FLAGS << flag
    end

    ##### Define CLI flags here #####

    flag short: "-f FORMAT", long: "--format FORMAT" do |f|
      f.desc = "format in which to present diffs (available options: [#{CheckPlease::Printers::FORMATS.join(", ")}])"
      f.set_key :format, :to_sym
    end

    flag short: "-n MAX_DIFFS", long: "--max-diffs MAX_DIFFS" do |f|
      f.desc = "Stop after encountering a specified number of diffs"
      f.set_key :max_diffs, :to_i
    end

    flag long: "--fail-fast" do |f|
      f.desc = "Stop after encountering the very first diff"
      f.set_key(:max_diffs) { 1 }
    end

    flag short: "-d MAX_DEPTH", long: "--max-depth MAX_DEPTH" do |f|
      f.desc = "Limit the number of levels to descend when comparing documents (NOTE: root has depth=1)"
      f.set_key :max_depth, :to_i
    end

  end

end
