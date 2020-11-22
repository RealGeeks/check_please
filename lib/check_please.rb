require 'yaml'
require 'json'

module CheckPlease
  autoload :CLI,        "check_please/cli"
  autoload :Comparison, "check_please/comparison"
  autoload :Diff,       "check_please/diff"
  autoload :Diffs,      "check_please/diffs"
  autoload :Error,      "check_please/error"
  autoload :Path,       "check_please/path"
  autoload :Printers,   "check_please/printers"
  autoload :Version,    "check_please/version"
end



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
    # Heck, maybe you even gave us some YAML!  We just don't know!
    # That's what makes it so exciting!
    def maybe_parse(document)

      case document
      when String ; return YAML.load(document) # don't worry, if this raises we'll assume you've already parsed it
      else        ; return document
      end

    rescue JSON::ParserError, Psych::SyntaxError
      return document
    end
  end
end
