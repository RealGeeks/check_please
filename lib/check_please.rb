require "check_please/version"
require "check_please/diff"
require "check_please/diffs"

module CheckPlease
  class Error < StandardError; end

  def self.diff(reference, candidate)
    Diffs.new(reference, candidate)
  end

end
