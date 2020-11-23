module CheckPlease
module CLI

  class Runner
    def initialize(exe_file_name)
      @parser = Parser.new(exe_file_name)
    end

    # NOTE: unusually for me, I'm using Ruby's `or` keyword in this method.
    # `or` short circuits just like `||`, but has lower precedence, which
    # enables some shenanigans...
    def run(*args)
      args.flatten!
      print_help_and_exit if args.empty?

      begin
        flags = @parser.flags_from_args!(args)
      rescue InvalidFlag => e
        print_help_and_exit e.message
      end

      # The reference MUST be the first arg...
      reference = \
        read_file(args.shift) \
        or print_help_and_exit "Missing <reference> argument"

      # The candidate MAY be the second arg, or it might have been piped in...
      candidate = \
        read_file(args.shift) \
        || read_piped_stdin \
        or print_help_and_exit "Missing <candidate> argument, AND nothing was piped in"

      # Looks like we're good to go!
      diff_view = CheckPlease.render_diff(reference, candidate, flags)
      puts diff_view
    end



    private

    def print_help_and_exit(message = nil)
      puts "\n>>> #{message}\n\n" if message
      puts @parser.help
      exit
    end

    def read_file(filename)
      return nil if filename.nil?
      File.read(filename)
    rescue Errno::ENOENT
      return nil
    end

    # Unfortunately, ARGF won't help us here because it doesn't seem to want to
    # read from stdin after it's already pulled a file out of ARGV.  So, we
    # have to read from stdin ourselves.
    #
    # BUT THAT'S NOT ALL!  If the user didn't actually pipe any data,
    # $stdin.read will block until they manually send EOF or hit Ctrl+C.
    #
    # Fortunately, we can detect whether $stdin.read will block by checking to
    # see if it is a TTY.  (Wait, what century is this again?)
    #
    # For fun and posterity, here's an experiment you can use to demonstrate this:
    #
    #   $ ruby -e 'puts $stdin.tty? ? "YES YOU ARE A TTY" : "nope, no tty here"'
    #   YES YOU ARE A TTY
    #
    #   $ cat foo | ruby -e 'puts $stdin.tty? ? "YES YOU ARE A TTY" : "nope, no tty here"'
    #   nope, no tty here
    def read_piped_stdin
      return nil if $stdin.tty?
      return $stdin.read
    end
  end

end
end
