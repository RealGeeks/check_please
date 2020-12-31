module CheckPlease

  class Path
    class AbstractSegment
      def self.new(name_or_instance = nil)
        case name_or_instance
        when self        ; name_or_instance
        when String, nil ; super
        else             ; raise ArgumentError
        end
      end

      attr_reader :name
      alias_method :to_s, :name

      def initialize(name)
        @name = name.to_s.strip
        complain_about_invalid_name! if @name =~ %r(\s)
        freeze
        validate_name!
      end

      def empty?
        name.empty?
      end

      private

      def validate_name!
        # subclass may override
      end

      def complain_about_invalid_name!
        msg = "#{name.inspect} is not a valid #{self.class} name!"
        raise ArgumentError, msg
      end
    end

    class Segment < AbstractSegment
      def key
        return nil unless name =~ /^([^=]+)=/
        $1.to_sym
      end

      def match?(segment_expr)
        if segment_expr.to_s.count(":").zero?
          return name == segment_expr.to_s # the easy way!
        else
          SegmentExpr.new(segment_expr).match?(name)
        end
      end

      private

      def validate_name!
        complain_about_invalid_name! if name.include?(":")
      end
    end

    class SegmentExpr < AbstractSegment
      def match?(segment_name)
        !!( segment_name.to_s =~ /^#{key}=/ )
      end

      def key
        name.sub(/^:/, "").to_sym
      end

      private

      def validate_name!
        complain_about_invalid_name! unless name.start_with?(":")
        complain_about_invalid_name! unless name.count(":") == 1
      end
    end
  end

  class Path
    SEPARATOR = "/"

    def self.root
      new
    end

    attr_reader :to_s, :segments
    def initialize(segments = [])
      case segments
      when String
        @segments = segments.split(SEPARATOR)
        @segments.shift until @segments.empty? || @segments.first.length > 0
      when nil, Array
        @segments = Array(segments)
      else
        raise ArgumentError, "not sure what to do with #{segments.inspect}"
      end
      @to_s = SEPARATOR + @segments.join(SEPARATOR)
      freeze
    end

    def +(new_basename)
      self.class.new( Array(@segments) + Array(new_basename.to_s) )
    end

    def basename
      segments.last.to_s
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

  class PathExpr < Path

  end

end
