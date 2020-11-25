module CheckPlease

  class Flag
    attr_accessor :name
    attr_writer   :default # reader is defined below
    attr_accessor :default_proc
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

    def default
      if default_proc
        default_proc.call
      else
        @default
      end
    end

    def coerce(&block)
      @coercer = block
    end

    def reentrant
      @reentrant = true
      self.default_proc = ->{ Array.new }
    end

    def validate(&block)
      @validator = block
    end

    protected

    def __set__(value, on:)
      val = _coerce(value)
      _validate(val)
      if @reentrant
        on[name] ||= []
        on[name].concat(Array(val))
      else
        on[name] = val
      end
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
