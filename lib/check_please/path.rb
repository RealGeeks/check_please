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
        names = name_or_segments.to_s.split(SEPARATOR)
        names.shift until names.empty? || names.first =~ /\S/
        segments = PathSegment.reify(names)
      when Array
        segments = PathSegment.reify(name_or_segments)
      else
        raise InvalidPath, "not sure what to do with #{name_or_segments.inspect}"
      end

      if segments.any?(&:empty?)
        raise InvalidPath, "#{self.class.name} cannot contain empty segments"
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
      list
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

		# TODO: Naming Things
    def key_for_compare(flags)
      mbk_exprs = unpack_mbk_exprs(flags)
      matches = mbk_exprs.select { |mbk_expr|
        # NOTE: matching on parent because path '/foo/:id' should return 'id' for path '/foo'
        mbk_expr.parent.match?(self)
      }

      case matches.length
      when 0 ; nil
      when 1 ; matches.first.segments.last.key
      else   ; raise "More than one match_by_key expression for path '#{self}': #{matches.map(&:to_s).inspect}"
      end
    end

    def match?(path_or_string)
      return true if self == path_or_string

      other = reify(path_or_string)
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

    # O(n^2) check to see if any of the path's ancestors are on a list
    # (as of this writing, this should never actually happen, but I'm being thorough)
    def ancestor_on_list?(paths)
      paths.any? { |path|
        ancestors.any? { |ancestor| ancestor == path }
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
      paths.any? { |path| self == path }
    end

    def too_deep?(flags)
      return false if flags.max_depth.nil?
      depth > flags.max_depth
    end

    def unpack_mbk_exprs(flags)
      flags.match_by_key
        .map { |path| path.send(:key_exprs) }
        .flatten
        .uniq { |e| e.to_s } # use the block form so we don't have to implement #hash and #eql? in horrible ways
    end

  end

end
