module CheckPlease

  module Reification
    def self.included(receiver)
      raise "This module adds class methods!  Please use `extend`, not `include`."
    end

    def reifiable
      @_reifiable ||= []
    end

    def can_reify(*klasses)
      klasses.flatten!

      unless ( klasses - [nil] ).all? { |e| e.is_a?(Class) }
        raise ArgumentError, "classes (or nil) only, please"
      end

      reifiable.concat klasses
      reifiable.uniq!
      nil
    end

    def reify(primitive_or_object)
      case primitive_or_object
      when self
        primitive_or_object
      when Array
        primitive_or_object.map { |e| reify(e) }
      when *reifiable
        new(primitive_or_object)
      else
        acceptable = reifiable.map { |e|
          begin
            e.name
          rescue NoMethodError
            e.inspect
          end
        }

        raise ArgumentError, <<~EOF
          #{self}.reify was given: #{primitive_or_object.inspect}
          but only accepts: #{acceptable.join(", ")}
        EOF
      end
    end
  end

end
