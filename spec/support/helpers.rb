def strip_trailing_whitespace(s)
  s.lines.map(&:rstrip).join("\n")
end

TIME_OUT_CLI_AFTER = 1 # seconds
def run_cli(*args, pipe: nil)
  args.flatten!

  cmd = []
  if pipe
    cmd << "cat"
    cmd << pipe
    cmd << "|"
  end
  cmd << "bin/check_please"
  cmd.concat << args

  out = nil # scope hack
  Timeout.timeout(TIME_OUT_CLI_AFTER) do
    out = `#{cmd.compact.join(' ')}`
  end
  strip_trailing_whitespace(out)
end
