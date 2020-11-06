require_relative "check_please/version"
require_relative "check_please/path"
require_relative "check_please/comparison"
require_relative "check_please/diff"
require_relative "check_please/diffs"
require_relative "check_please/printers"

module CheckPlease
  class Error < StandardError; end

  def self.diff(reference, candidate)
    reference = maybe_parse(reference)
    candidate = maybe_parse(candidate)
    Comparison.perform(reference, candidate)
  end

  def self.render_diff(reference, candidate, format: nil)
    diffs = diff(reference, candidate)
    Printers.render(diffs, format)
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
