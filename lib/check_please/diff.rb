module CheckPlease

  class Diff
    attr_reader :type, :reference, :candidate, :path
    def initialize(type, reference, candidate, path)
      @type      = type
      @reference = reference
      @candidate = candidate
      @path      = path.to_s
    end

    def ref_display
      reference.inspect
    end

    def can_display
      candidate.inspect
    end

    def inspect
      s = "<"
      s << self.class.name
      s << " ref=#{ref_display}"
      s << " can=#{can_display}"
      s << " type=#{type}" if type
      s << ">"
      s
    end
  end

end
