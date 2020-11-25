require 'yaml'
require 'json'


# easier to just require these
require "check_please/error"
require "check_please/version"

module CheckPlease
  autoload :CLI,         "check_please/cli"
  autoload :Comparison,  "check_please/comparison"
  autoload :Diff,        "check_please/diff"
  autoload :Diffs,       "check_please/diffs"
  autoload :Flag,        "check_please/flag"
  autoload :Flags,       "check_please/flags"
  autoload :Path,        "check_please/path"
  autoload :Printers,    "check_please/printers"
  autoload :Refinements, "check_please/refinements"
end



module CheckPlease
  ELEVATOR_PITCH = "Tool for parsing and diffing two JSON documents."

  def self.diff(reference, candidate, flags = {})
    reference = maybe_parse(reference)
    candidate = maybe_parse(candidate)
    Comparison.perform(reference, candidate, flags)
  end

  def self.render_diff(reference, candidate, flags = {})
    diffs = diff(reference, candidate, flags)
    Printers.render(diffs, flags)
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



  Flags.define :format do |flag|
    allowed_values = CheckPlease::Printers::FORMATS.sort

    flag.coerce &:to_sym
    flag.default = CheckPlease::Printers::DEFAULT_FORMAT
    flag.validate { |value| allowed_values.include?(value) }

    flag.cli_long = "--format FORMAT"
    flag.cli_short = "-f FORMAT"
    flag.description = [
      "Format in which to present diffs.",
      "  (Allowed values: [#{allowed_values.join(", ")}])",
    ]
  end

  Flags.define :max_diffs do |flag|
    flag.coerce &:to_i
    flag.validate { |value| value.to_i > 0 }

    flag.cli_long = "--max-diffs MAX_DIFFS"
    flag.cli_short = "-n MAX_DIFFS"
    flag.description = "Stop after encountering a specified number of diffs."
  end

  Flags.define :fail_fast do |flag|
    flag.default = false
    flag.coerce { |value| !!value }

    flag.cli_long = "--fail-fast"
    flag.description = [
      "Stop after encountering the first diff.",
      "  (equivalent to '--max-diffs 1')",
    ]
  end

  Flags.define :max_depth do |flag|
    flag.coerce &:to_i
    flag.validate { |value| value.to_i > 0 }

    flag.cli_long = "--max_depth MAX_DEPTH"
    flag.cli_short = "-d MAX_DEPTH"
    flag.description = [
      "Limit the number of levels to descend when comparing documents.",
      "  (NOTE: root has depth = 1)",
    ]
  end

  Flags.define :select_paths do |flag|
    flag.reentrant

    flag.cli_long = "--select-paths PATH_EXPR"
    flag.description = [
      "ONLY record diffs matching the provided PATH expression.",
      "  May be repeated; values will be treated as an 'OR' list.",
    ]
  end

  Flags.define :reject_paths do |flag|
    flag.reentrant

    flag.cli_long = "--reject-paths PATH_EXPR"
    flag.description = [
      "DON'T record diffs matching the provided PATH expression.",
      "  May be repeated; values will be treated as an 'OR' list.",
    ]
  end

end
