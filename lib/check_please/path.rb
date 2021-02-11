module CheckPlease

  # TODO: this class is getting a bit large; maybe split out some of the stuff that uses flags?
  class Path
    include CheckPlease::Reification
    can_reify String, Symbol, Numeric, nil

    SEPARATOR = "/"

    def self.root
      new('/')
    end



    attr_reader :to_s, :segments
    def initialize(name_or_segments = [])
      case name_or_segments
      when String, Symbol, Numeric, nil
        string = name_or_segments.to_s
        if string =~ %r(//)
          raise InvalidPath, "paths cannot have empty segments"
        end

        names = string.split(SEPARATOR)
        names.shift until names.empty? || names.first =~ /\S/
        segments = PathSegment.reify(names)
      when Array
        segments = PathSegment.reify(name_or_segments)
      else
        raise InvalidPath, "not sure what to do with #{name_or_segments.inspect}"
      end

      @segments = Array(segments)

      @to_s = SEPARATOR + @segments.join(SEPARATOR)
      freeze
    rescue InvalidPathSegment => e
      raise InvalidPath, e.message
    end

    def +(new_basename)
      new_segments = self.segments.dup
      new_segments << new_basename # don't reify here; it'll get done on Path#initialize
      self.class.new(new_segments)
    end

    def ==(other)
      self.to_s == other.to_s
    end

    def ancestors
      list = []
      p = self
      loop do
        break if p.root?
        p = p.parent
        list.unshift p
      end
      list.reverse
    end

    def basename
      segments.last.to_s
    end

    def depth
      1 + segments.length
    end

    def excluded?(flags)
      return false if root? # that would just be silly

      return true if too_deep?(flags)
      return true if explicitly_excluded?(flags)
      return true if implicitly_excluded?(flags)

      false
    end

    def inspect
      "<#{self.class.name} '#{to_s}'>"
    end

    def key_to_match_by(flags)
      key_exprs = unpack_key_exprs(flags.match_by_key)
      # NOTE: match on parent because if self.to_s == '/foo', MBK '/foo/:id' should return 'id'
      matches = key_exprs.select { |e| e.parent.match?(self) }

      case matches.length
      when 0 ; nil
      when 1 ; matches.first.segments.last.key
      else   ; raise "More than one match_by_key expression for path '#{self}': #{matches.map(&:to_s).inspect}"
      end
    end

    def match_by_value?(flags)
      flags.match_by_value.any? { |e| e.match?(self) }
    end

    def match?(path_or_string)
      # If the strings are literally equal, we're good..
      return true if self == path_or_string

      # Otherwise, compare segments: do we have the same number, and do they all #match?
      other = reify(path_or_string)
      return false if other.depth != self.depth

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

    # O(n^2) check to see if any of the path's ancestors are on a list
    # (as of this writing, this should never actually happen, but I'm being thorough)
    def ancestor_on_list?(paths)
      paths.any? { |path|
        ancestors.any? { |ancestor| ancestor.match?(path) }
      }
    end

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

    # A path of "/foo/:id/bar/:name" has two key expressions:
    # - "/foo/:id"
    # - "/foo/:id/bar/:name"
    def key_exprs
      ( [self] + ancestors )
        .reject { |path| path.root? }
        .select { |path| path.segments.last&.key_expr? }
    end

    # O(n) check to see if the path itself is on a list
    def self_on_list?(paths)
      paths.any? { |path| self.match?(path) }
    end

    def too_deep?(flags)
      return false if flags.max_depth.nil?
      depth > flags.max_depth
    end

    def unpack_key_exprs(path_list)
      path_list
        .map { |path| path.send(:key_exprs) }
        .flatten
        .uniq { |e| e.to_s } # use the block form so we don't have to implement #hash and #eql? in horrible ways
    end

  end

end
