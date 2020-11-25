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

    def excluded?(flags)
      s = to_s ; matches = ->(path_expr) { s.include?(path_expr) }
      if flags.select_paths.length > 0
        return flags.select_paths.none?(&matches)
      end
      false
    end

    def to_s
      SEPARATOR + @segments.join(SEPARATOR)
    end

    def inspect
      to_s
    end
  end

end
