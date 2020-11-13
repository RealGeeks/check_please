require 'optparse'

module CheckPlease
module CLI

  class Parser
    class UnrecognizedOption < StandardError
      include CheckPlease::Error
    end

    def initialize(exe_file_name)
      @exe_file_name = exe_file_name
      @optparse = OptionParser.new
      @optparse.banner = banner

      @options = {} # yuck
      CheckPlease::CLI::FLAGS.each do |flag|
        flag.visit_option_parser(@optparse, @options)
      end
    end

    # Unfortunately, OptionParser *really* wants to use closures.
    # I haven't yet figured out how to get around this...
    def consume_flags!(args)
      @optparse.parse!(args) # removes recognized flags from `args`
      return @options
    rescue OptionParser::InvalidOption, OptionParser::AmbiguousOption => e
      raise UnrecognizedOption, e.message, cause: e
    end

    def help
      @optparse.help
    end

    private

    def banner
      <<~EOF
        Usage: #{@exe_file_name} <reference> <candidate> [FLAGS]

          #{CheckPlease::ELEVATOR_PITCH}

          Arguments:
            <reference> is the name of a file to use as, well, the reference.
            <candidate> is the name of a file to compare against the reference.

            NOTE: If you have a utility like MacOS's `pbpaste`, you MAY omit
            the <candidate> arg, and pipe the second document instead, like:

              $ pbpaste | #{@exe_file_name} <reference>

          FLAGS:
      EOF
    end
  end

end
end
