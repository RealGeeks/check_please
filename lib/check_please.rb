require "check_please/version"
require "check_please/path"
require "check_please/comparison"
require "check_please/diff"
require "check_please/diffs"

module CheckPlease
  class Error < StandardError; end

  def self.diff(reference, candidate)
    Comparison.perform(reference, candidate)
  end
end
