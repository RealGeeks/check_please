require 'optparse'

module CheckPlease
module CLI

  class Parser
    def initialize(exe_file_name)
      @exe_file_name = File.basename(exe_file_name)
    end

    # Unfortunately, OptionParser *really* wants to use closures.  I haven't
    # yet figured out how to get around this, but at least it's closing on a
    # local instead of an ivar... progress?
    def flags_from_args!(args)
      flags = Flags.new
      optparse = option_parser(flags: flags)
      optparse.parse!(args) # removes recognized flags from `args`
      return flags
    rescue OptionParser::InvalidOption, OptionParser::AmbiguousOption => e
      raise InvalidFlag, e.message, cause: e
    end

    def help
      option_parser.help
    end

    private

    # NOTE: if flags is nil, you'll get something that can print help, but will explode when sent :parse
    def option_parser(flags: nil)
      OptionParser.new.tap do |optparse|
        optparse.banner = banner
        CheckPlease::Flags.each_flag do |flag|
          args = [ flag.cli_short, flag.cli_long, flag.description ].flatten.compact
          optparse.on(*args) do |value|
            flags.send "#{flag.name}=", value
          end
        end
      end
    end

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
