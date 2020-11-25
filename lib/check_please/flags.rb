module CheckPlease

  # NOTE: this gets all of its attributes defined (via .define) in ../check_please.rb

  class Flags
    BY_NAME = {} ; private_constant :BY_NAME

    def self.define(name, &block)
      flag = Flag.new(name: name, &block)
      BY_NAME[flag.name] = flag
      define_accessors flag

      nil
    end

    def self.each_flag
      BY_NAME.each do |_, flag|
        yield flag
      end
    end

    def self.define_accessors(flag)
      getter = flag.name
      define_method(getter) {
        @attributes.fetch(flag.name) { flag.default }
      }

      setter = :"#{flag.name}="
      define_method(setter) { |value|
        flag.send :__set__, value, on: @attributes
      }
    end

    def initialize(attrs = {})
      @attributes = {}
      attrs.each do |name, value|
        send "#{name}=", value
      end
    end
  end

end
