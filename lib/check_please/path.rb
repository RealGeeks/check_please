module CheckPlease

  class Path
    SEPARATOR = "/"

    def self.root
      new
    end

    attr_reader :to_s
    def initialize(segments = [])
      @segments = Array(segments)
      @to_s = SEPARATOR + @segments.join(SEPARATOR)
      freeze
    end

    def +(new_basename)
      self.class.new( Array(@segments) + Array(new_basename.to_s) )
    end

    def depth
      1 + @segments.length
    end

    def excluded?(flags)
      return false if root?

      return true if too_deep?(flags)
      return true if explicitly_excluded?(flags)
      return true if implicitly_excluded?(flags)

      false
    end

    def inspect
      "<CheckPlease::Path '#{to_s}'>"
    end

    def root?
      to_s == SEPARATOR
    end

    private

    def explicitly_excluded?(flags)
      flags.reject_paths.any?( &method(:match?) )
    end

    def implicitly_excluded?(flags)
      return false if flags.select_paths.empty?
      flags.select_paths.none?( &method(:match?) )
    end

    # leaving this here for a while in case it needs to grow into a public method
    def match?(path_expr)
      to_s.include?(path_expr)
    end

    def too_deep?(flags)
      return false if flags.max_depth.nil?
      flags.max_depth + 1 < depth
    end
  end

end
