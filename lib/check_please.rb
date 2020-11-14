require_relative "check_please/version"
require_relative "check_please/error"
require_relative "check_please/path"
require_relative "check_please/comparison"
require_relative "check_please/diff"
require_relative "check_please/diffs"
require_relative "check_please/printers"
require_relative "check_please/cli"

module CheckPlease
  ELEVATOR_PITCH = "Tool for parsing and diffing two JSON documents."

  def self.diff(reference, candidate, options = {})
    reference = maybe_parse(reference)
    candidate = maybe_parse(candidate)
    Comparison.perform(reference, candidate, options)
  end

  def self.render_diff(reference, candidate, options = {})
    diffs = diff(reference, candidate, options)
    Printers.render(diffs, options)
  end

  class << self
    private

    # Maybe you gave us JSON strings, maybe you gave us Ruby objects.
    # We just don't know!  That's what makes it so exciting!
    def maybe_parse(maybe_json)

      case maybe_json
      when String ; JSON.parse(maybe_json) # don't worry, if this raises we'll assume you've already parsed it
      else        ; maybe_json
      end

    rescue JSON::ParserError
      return maybe_json
    end
  end
end
