module CheckPlease

  module Reification
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

    module ClassMethods
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
        when self       ; return primitive_or_object
        when Array      ; return primitive_or_object.map { |e| reify(e) }
        when *reifiable ; return new(primitive_or_object)
        end

        # that didn't work? complain!
        acceptable = reifiable.map { |e| Class === e ? e.name : e.inspect }
        raise ArgumentError, <<~EOF
          #{self}.reify was given: #{primitive_or_object.inspect}
          but only accepts: #{acceptable.join(", ")}
        EOF
      end
    end

    module InstanceMethods
      def reify(x)
        self.class.reify(x)
      end
    end
  end

end
