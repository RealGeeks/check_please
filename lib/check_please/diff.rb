module CheckPlease

  class Diff
    attr_reader :reference, :candidate, :path
    def initialize(reference, candidate, path)
      @reference = reference
      @candidate = candidate
      @path      = path
    end
  end

end
