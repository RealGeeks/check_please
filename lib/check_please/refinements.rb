module CheckPlease

  module Refinements
    refine Kernel do
      def Flags(flags_or_hash)
        case flags_or_hash
        when Flags ; return flags_or_hash
        when Hash  ; return Flags.new(flags_or_hash)
        else
          raise ArgumentError, "Expected either a CheckPlease::Flags or a Hash; got #{flags_or_hash.inspect}"
        end
      end
    end
  end

end
