module CheckPlease

  class PathSegment
    class IllegalName < ArgumentError
      include CheckPlease::Error
    end

    # FIXME: is this really necessary?
    def self.new(name_or_instance = nil)
      case name_or_instance
      when self
        name_or_instance
      when String, Symbol, Numeric, nil
        super
      else
        raise IllegalName, "wtf is a #{name_or_instance.inspect} ?"
      end
    end

    attr_reader :name, :key, :key_value
    alias_method :to_s, :name

    def initialize(name)
      @name = name.to_s.strip
      complain_about_invalid_name!(name) if @name =~ %r(\s)
      parse_key_and_value
      freeze
      validate!
    end

    def empty?
      name.empty?
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
      when /^\:([^\:]+)$/     # starts with a colon; doesn't have any further colons
        @key = $1
      when /^([^=]+)=([^=]+)$/ # has exactly one '=' sign, with at least one character on either side of it
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
