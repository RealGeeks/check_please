module CheckPlease

  class Flag
    attr_accessor :name
    attr_writer   :default # reader is defined below
    attr_accessor :default_proc
    attr_accessor :description
    attr_accessor :cli_long
    attr_accessor :cli_short

    def initialize(attrs = {})
      @validators = []
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

    def description=(value)
      if value.is_a?(String) && value =~ /\n/m
        lines = value.lines
      else
        lines = Array(value).map(&:to_s)
      end

      @description = lines.map(&:rstrip)
    end

    def mutually_exclusive_to(flag_name)
      @validators << ->(flags, _) { flags.send(flag_name).empty? }
    end

    def reentrant
      @reentrant = true
      self.default_proc = ->{ Array.new }
    end

    def validate(&block)
      @validators << block
    end

    protected

    def __set__(value, on:, flags:)
      val = _coerce(value)
      _validate(flags, val)
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

    def _validate(flags, value)
      return if @validators.empty?
      return if @validators.all? { |block| block.call(flags, value) }
      raise InvalidFlag, "#{value.inspect} is not a legal value for #{name}"
    end

    def set_attribute!(name, value)
      self.send "#{name}=", value
    rescue NoMethodError
      raise ArgumentError, "unrecognized attribute: #{name}"
    end
  end

end
