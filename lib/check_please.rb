require "check_please/version"
require "check_please/path"
require "check_please/comparison"
require "check_please/diff"
require "check_please/diffs"
require "check_please/printers"

module CheckPlease
  class Error < StandardError; end

  def self.diff(reference, candidate)
    Comparison.perform(reference, candidate)
  end

  def self.render_diff(reference, candidate, format: nil)
    diffs = diff(reference, candidate)
    Printers.render(diffs, format)
  end
end
