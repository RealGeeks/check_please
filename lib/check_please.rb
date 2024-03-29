require 'yaml'
require 'json'


# easier to just require these
require "check_please/error"
require "check_please/version"

module CheckPlease
  autoload :Reification,        "check_please/reification"
  autoload :CLI,                "check_please/cli"
  autoload :Comparison,         "check_please/comparison"
  autoload :Diff,               "check_please/diff"
  autoload :Diffs,              "check_please/diffs"
  autoload :Flag,               "check_please/flag"
  autoload :Flags,              "check_please/flags"
  autoload :Path,               "check_please/path"
  autoload :PathSegment,        "check_please/path_segment"
  autoload :PathSegmentMatcher, "check_please/path_segment_matcher"
  autoload :Printers,           "check_please/printers"
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
    flag.validate { |flags, value| allowed_values.include?(value) }

    flag.cli_long = "--format FORMAT"
    flag.cli_short = "-f FORMAT"
    flag.description = <<~EOF
      Format in which to present diffs.
        (Allowed values: [#{allowed_values.join(", ")}])
    EOF
  end

  Flags.define :max_diffs do |flag|
    flag.coerce &:to_i
    flag.validate { |flags, value| value.to_i > 0 }

    flag.cli_long = "--max-diffs MAX_DIFFS"
    flag.cli_short = "-n MAX_DIFFS"
    flag.description = "Stop after encountering a specified number of diffs."
  end

  Flags.define :fail_fast do |flag|
    flag.default = false
    flag.coerce { |value| !!value }
    flag.cli_long = "--fail-fast"
    flag.description = <<~EOF
      Stop after encountering the first diff.
        (equivalent to '--max-diffs 1')
    EOF
  end

  Flags.define :max_depth do |flag|
    flag.coerce &:to_i
    flag.validate { |flags, value| value.to_i > 0 }

    flag.cli_long = "--max_depth MAX_DEPTH"
    flag.cli_short = "-d MAX_DEPTH"
    flag.description = <<~EOF
      Limit the number of levels to descend when comparing documents.
        (NOTE: root has depth = 1)
    EOF
  end

  Flags.define :select_paths do |flag|
    flag.repeatable
    flag.mutually_exclusive_to :reject_paths
    flag.coerce { |value| CheckPlease::Path.reify(value) }

    flag.cli_short = "-s PATH_EXPR"
    flag.cli_long = "--select-paths PATH_EXPR"
    flag.description = <<~EOF
      ONLY record diffs matching the provided PATH expression.
        May be repeated; values will be treated as an 'OR' list.
        Can't be combined with --reject-paths.
    EOF
  end

  Flags.define :reject_paths do |flag|
    flag.repeatable
    flag.mutually_exclusive_to :select_paths
    flag.coerce { |value| CheckPlease::Path.reify(value) }

    flag.cli_short = "-r PATH_EXPR"
    flag.cli_long = "--reject-paths PATH_EXPR"
    flag.description = <<~EOF
      DON'T record diffs matching the provided PATH expression.
        May be repeated; values will be treated as an 'OR' list.
        Can't be combined with --select-paths.
    EOF
  end

  Flags.define :match_by_key do |flag|
    flag.repeatable
    flag.coerce { |value| CheckPlease::Path.reify(value) }

    flag.cli_long = "--match-by-key FOO"
    flag.description = <<~EOF
      Specify how to match reference/candidate pairs in arrays of hashes.
        May be repeated; values will be treated as an 'OR' list.
        See the README for details on how to actually use this.
        NOTE: this does not yet handle non-string keys.
    EOF
  end

  Flags.define :match_by_value do |flag|
    flag.repeatable
    flag.coerce { |value| CheckPlease::Path.reify(value) }

    flag.cli_long = "--match-by-value FOO"
    flag.description = <<~EOF
      When comparing two arrays that match a specified path, the candidate
      array will be scanned for each element in the reference array.
        May be repeated; values will be treated as an 'OR' list.
        NOTE: explodes if either array at a given path contains other collections.
        NOTE: paths of 'extra' diffs use the index in the candidate array.
    EOF
  end

  Flags.define :indifferent_keys do |flag|
    flag.default = false
    flag.coerce { |value| !!value }

    flag.cli_long = "--indifferent-keys"
    flag.description = <<~EOF
      When comparing hashes, convert symbol keys to strings
    EOF
  end

  Flags.define :indifferent_values do |flag|
    flag.default = false
    flag.coerce { |value| !!value }

    flag.cli_long = "--indifferent-values"
    flag.description = <<~EOF
      When comparing values (that aren't arrays or hashes), convert symbols to strings
    EOF
  end

  Flags.define :normalize_values do |flag|
    # NOTE: This flag is only accessible via the Ruby API.
    #       See the README for documentation.
  end

end
