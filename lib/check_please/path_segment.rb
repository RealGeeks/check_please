module CheckPlease

  class PathSegment
    extend CheckPlease::Reification
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
      if @name =~ %r(\s) # has any whitespace
        raise InvalidPathSegment, <<~EOF
          #{name.inspect} is not a valid #{self.class} name
        EOF
      end
      parse_key_and_value
      freeze
    end

    def empty?
      name.empty?
    end

    def key_expr?
      name.match?(KEY_EXPR)
    end

    def key_val_expr?
      name.match?(KEY_VAL_EXPR)
    end

    def match?(other_segment_or_string)
      other = self.class.reify(other_segment_or_string)

      match_types = [ self.match_type, other.match_type ]
      case match_types
      when [ :plain,     :plain     ] ; self.name == other.name
      when [ :key,       :key_value ] ; self.key  == other.key
      when [ :key_value, :key       ] ; self.key  == other.key
      else                            ; false
      end
    end

    protected

    def match_type
      return :key       if key_expr?
      return :key_value if key_val_expr?
      :plain
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
