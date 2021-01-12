module CheckPlease

  autoload :InvalidPathSegment, "check_please/path_segment"

  class InvalidPath < ArgumentError
    include CheckPlease::Error
  end



  class Path
    SEPARATOR = "/"

    def self.root
      new('/')
    end



    attr_reader :to_s, :segments
    def initialize(name_or_segments = [])
      case name_or_segments
      when String, Symbol, Numeric, nil
        maybe_segments = name_or_segments.to_s.split(SEPARATOR)
        maybe_segments.shift until maybe_segments.empty? || maybe_segments.first =~ /\S/
      when Array
        maybe_segments = name_or_segments
      else
        raise InvalidPath, "not sure what to do with #{name_or_segments.inspect}"
      end

      segments = Array(maybe_segments).map { |e| PathSegment.new(e) }
      if segments.any?(&:empty?)
        raise InvalidPath, "#{self.class.name} cannot contain empty segments"
      end

      @segments = Array(segments)

      @to_s = SEPARATOR + @segments.join(SEPARATOR)
      freeze
    rescue PathSegment::IllegalName => e
      raise InvalidPath, e.message
    end

    def +(new_basename)
      new_segments = ( self.segments + Array(new_basename) ).map { |e| PathSegment.new(e) }
      self.class.new(new_segments)
    end

    def ==(other)
      self.to_s == other.to_s
    end

    def ancestors
      list = []
      p = self
      loop do
        p = p.parent
        break if p.nil?
        list.unshift p
      end
      list
    end

    def basename
      segments.last.to_s
    end

    def depth
      1 + segments.length
    end

    def excluded?(flags)
      return false if root?

      return true if too_deep?(flags)
      return true if explicitly_excluded?(flags)
      return true if implicitly_excluded?(flags)

      false
    end

    def inspect
      "<#{self.class.name} '#{to_s}'>"
    end

    def key_for_compare(flags)
      mbk_exprs = flags.match_by_key.select { |mbk| match?(mbk) }
      case mbk_exprs.length
      when 0 ; nil
      when 1 ; self.class.new(mbk_exprs.first).segments.last.key
      else   ; raise "More than one match_by_key expression for path '#{self}'"
      end
    end

    def match?(path_or_string)
      return true if self == path_or_string

      other = self.class.new(path_or_string)
      return false unless other.segments.length == self.segments.length
      seg_pairs = self.segments.zip(other.segments)
      seg_pairs.all? { |a, b| a.match?(b) }
    end

    def parent
      return nil if root? # TODO: consider the Null Object pattern
      self.class.new(segments[0..-2])
    end

    def root?
      @segments.empty?
    end

    private

    def explicitly_excluded?(flags)
      return false if flags.reject_paths.empty?
      return true if self_on_list?(flags.reject_paths)
      return true if ancestor_on_list?(flags.reject_paths)
      false
    end

    def implicitly_excluded?(flags)
      return false if flags.select_paths.empty?
      return false if self_on_list?(flags.select_paths)
      return false if ancestor_on_list?(flags.select_paths)
      true
    end

    def too_deep?(flags)
      return false if flags.max_depth.nil?
      depth > flags.max_depth
    end

    # O(n) check to see if the path itself is on a list
    def self_on_list?(paths)
      paths.any? { |path| self == path }
    end

    # O(n^2) check to see if any of the path's ancestors are on a list
    # (as of this writing, this should never actually happen, but I'm being thorough)
    def ancestor_on_list?(paths)
      paths.any? { |path|
        ancestors.any? { |ancestor| ancestor == path }
      }
    end
  end

end
