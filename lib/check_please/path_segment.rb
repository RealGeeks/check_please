module CheckPlease

  class PathSegment
    include CheckPlease::Reification
    can_reify String, Symbol, Numeric, nil

    KEY_EXPR = %r{
      ^
      \:       # a literal colon
      (        # capture key
        [^\:]+ # followed by one or more things that aren't colons
      )        # end capture key
      $
    }x

    KEY_VAL_EXPR = %r{
      ^
      (       # capture key
        [^=]+ # stuff (just not an equal sign)
      )       # end capture key
      \=      # an equal sign
      (       # capture key value
        [^=]+ # stuff (just not an equal sign)
      )       # end capture key value
      $
    }x

    attr_reader :name, :key, :key_value
    alias_method :to_s, :name

    def initialize(name = nil)
      @name = name.to_s.strip

      case @name
      when "", /\s/ # blank or has any whitespace
        raise InvalidPathSegment, "#{name.inspect} is not a valid #{self.class} name"
      end

      parse_key_and_value
      freeze
    end

    def key_expr?
      name.match?(KEY_EXPR)
    end

    def key_val_expr?
      name.match?(KEY_VAL_EXPR)
    end

    def match?(other_segment_or_string)
      other = reify(other_segment_or_string)
      PathSegmentMatcher.call(self, other)
    end

    def splat?
      name == '*'
    end

    private

    def parse_key_and_value
      case name
      when KEY_EXPR
        @key = $1
      when KEY_VAL_EXPR
        @key, @key_value = $1, $2
      else
        # :nothingtodohere:
      end
    end
  end

end
