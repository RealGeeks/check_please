module CheckPlease

  class PathSegment
    class IllegalName < ArgumentError
      include CheckPlease::Error
    end

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

    def self.reify(name_or_instance = nil)
      case name_or_instance
      when self
        name_or_instance
      when String, Symbol, Numeric, nil
        new(name_or_instance)
      else
        raise IllegalName, "wtf is a #{name_or_instance.inspect} ?"
      end
    end

    attr_reader :name, :key, :key_value
    alias_method :to_s, :name

    def initialize(name = nil)
      @name = name.to_s.strip
      complain_about_invalid_name!(name) if @name =~ %r(\s)
      parse_key_and_value
      freeze
      validate!
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
      other = self.class.new(other_segment_or_string)

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
      has_key       = key       .to_s.length > 0
      has_key_value = key_value .to_s.length > 0

      return :key_value if has_key &&  has_key_value
      return :key       if has_key && !has_key_value
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

    def validate!
      # subclass may override
    end

    def complain_about_invalid_name!(original_name)
      msg = "#{name.inspect} is not a valid #{self.class} name! (given #{original_name.inspect})"
      raise IllegalName, msg
    end

  end

end
