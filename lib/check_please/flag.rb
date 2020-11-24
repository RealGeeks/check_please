module CheckPlease

  class Flag
    attr_accessor :name
    attr_accessor :default
    attr_accessor :description
    attr_accessor :cli_long
    attr_accessor :cli_short

    def initialize(attrs = {})
      attrs.each do |name, value|
        set_attribute! name, value
      end
      yield self if block_given?
      freeze
    end

    def coerce(&block)
      @coercer = block
    end

    def validate(&block)
      @validator = block
    end

    def coerce_and_validate(value)
      val = _coerce(value)
      _validate(val)
      return val
    end

    private

    def _coerce(value)
      return value if @coercer.nil?
      @coercer.call(value)
    end

    def _validate(value)
      return if @validator.nil?
      return if @validator.call(value) == true
      raise InvalidFlag, "#{value.inspect} is not a legal value for #{name}"
    end

    def set_attribute!(name, value)
      self.send "#{name}=", value
    rescue NoMethodError
      raise ArgumentError, "unrecognized attribute: #{name}"
    end
  end

end
