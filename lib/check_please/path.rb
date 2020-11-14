module CheckPlease

  class Path
    SEPARATOR = "/"

    def initialize(segments = [])
      @segments = Array(segments)
    end

    def +(new_basename)
      self.class.new( Array(@segments) + Array(new_basename.to_s) )
    end

    def depth
      1 + @segments.length
    end

    def to_s
      SEPARATOR + @segments.join(SEPARATOR)
    end

    def inspect
      to_s
    end
  end

end
