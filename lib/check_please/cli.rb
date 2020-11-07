require 'optparse'

module CheckPlease

  class CLI
    attr_reader :exe_file_name, :diff_opts
    def initialize(exe_file_name)
      @exe_file_name = exe_file_name
      @diff_opts = {}
    end

    # TODO:
    # - diff_opts magically appears at the end; see if it can be made more explicit
    #   - but know that this might mean passing it to option_parser?
    # - after consume_recognized_options_from_argv!, check ARGV for unrecognized leftovers

    # NOTE: unusually for me, I'm using Ruby's `or` keyword in this method.
    # `or` short circuits just like `||`, but has lower precedence, which
    # enables some shenanigans...
    def run
      consume_recognized_options_from_argv!

      # The reference MUST be the first arg...
      reference = \
        read_file(ARGV.shift) \
        or print_help_and_exit "Missing argument: <reference>"

      # The candidate MAY be the second arg, or it might have been piped in.
      #
      # Unfortunately, ARGF won't help us here because it doesn't seem to want
      # to read from stdin after pulling files off of ARGV.  So,
      # #read_piped_stdin is slightly tricksy...
      candidate = \
        read_file(ARGV.shift) \
        || read_piped_stdin \
        or print_help_and_exit "Missing argument: <candidate>, AND nothing was piped in"

      # OK, we're good to go!
      diff_view = CheckPlease.render_diff(reference, candidate, **diff_opts)
      puts diff_view

    rescue FileNotFound => e
      puts e.message
    end



    private

    def consume_recognized_options_from_argv!
      # Calling #parse! instead of #parse will "eat" recognized flags, leaving only filenames
      # (aka "TIL I've been using ARGV all wrong")
      option_parser.parse!(ARGV)
    rescue OptionParser::InvalidOption, OptionParser::AmbiguousOption => e
      print_help_and_exit e.message
    end

    def option_parser
      @_option_parser ||=
        OptionParser.new do |opts|
          opts.banner = <<~EOF
            Usage: #{exe_file_name} <reference> <candidate> [FLAGS]

              Tool for parsing and diffing two JSON documents.

              Arguments:
                <reference> is the name of a file to use as, well, the reference.
                <candidate> is the name of a file to compare against the reference.

                NOTE: If you have a utility like MacOS's `pbpaste`, you MAY omit
                the <candidate> arg, and pipe the second document instead, like:

                  $ pbpaste | #{exe_file_name} <reference>

              FLAGS:
          EOF

          formats = CheckPlease::Printers::FORMATS.join(", ")

          opts.on("-f FORMAT", "--format FORMAT", "specify the format (available options: [#{formats}]") do |val|
            diff_opts[:format] = val
          end
        end
    end

    def print_help_and_exit(message = nil)
      puts "\n>>> #{message}\n\n" if message
      option_parser.parse(%w[--help])
      exit # technically redundant but helps me feel better
    end

    def read_file(filename)
      return nil if filename.nil?
      File.read(filename)
    rescue Errno::ENOENT
      return nil
    end

    def read_piped_stdin
      # As mentioned above, ARGF doesn't fit the way this CLI was designed.
      #
      # And, if the user didn't actually pipe any data, $stdin.read will block
      # until they manually send an EOF (i.e., forever).
      #
      # So, we check to see if stdin is a TTY (what century is this again?)
      # before trying to #read from it.

      return nil if $stdin.tty?
      return $stdin.read

      # For fun and posterity, here's an experiment you can use to demonstrate this:
      #
      #   $ ruby -e 'puts $stdin.tty? ? "YES YOU ARE A TTY" : "nope, no tty here"'
      #   YES YOU ARE A TTY
      #
      #   $ cat foo | ruby -e 'puts $stdin.tty? ? "YES YOU ARE A TTY" : "nope, no tty here"'
      #   nope, no tty here
    end
  end

end
