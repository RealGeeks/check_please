module CheckPlease
module CLI

  class Flag
    ATTR_NAMES = %i[ short long desc key block ]
    attr_accessor(*ATTR_NAMES)

    def initialize
      yield self if block_given?
      missing = ATTR_NAMES.select { |e| self.send(e).nil? }
      if missing.any?
        raise ArgumentError, "Missing attributes: #{missing.join(', ')}"
      end
    end

    def visit_option_parser(parser, options)
      parser.on(short, long, desc) do |value|
        block.call options, value
      end
    end

    def set_key(key, message = nil, &b)
      raise ArgumentError if message && b
      raise ArgumentError if !message && !b

      self.key = key
      self.block = ->(options, value) {
        b ||= message.to_sym.to_proc
        options[key] = b.call(value)
      }
    end
  end

end
end
