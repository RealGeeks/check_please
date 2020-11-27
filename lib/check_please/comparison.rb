module CheckPlease
  using Refinements

  class Comparison
    def self.perform(reference, candidate, flags = {})
      new.perform(reference, candidate, flags)
    end

    def perform(reference, candidate, flags = {})
      @flags = Flags(flags) # whoa, it's almost like Java in here
      @diffs = Diffs.new(flags: @flags)

      catch(:max_diffs_reached) do
        compare reference, candidate, CheckPlease::Path.root
      end
      diffs
    end

    private
    attr_reader :diffs, :flags

    def compare(ref, can, path)
      return if path.excluded?(flags)

      case types(ref, can)
      when [ :array, :array ] ; compare_arrays ref, can, path
      when [ :hash,  :hash  ] ; compare_hashes ref, can, path
      when [ :other, :other ] ; compare_others ref, can, path
      else
        record_diff ref, can, path, :type_mismatch
      end
    end

      def types(*list)
        list.map { |e|
          case e
          when Array ; :array
          when Hash  ; :hash
          else       ; :other
          end
        }
      end

      def compare_arrays(ref_array, can_array, path)
        max_len = [ ref_array, can_array ].map(&:length).max
        (0...max_len).each do |i|
          n = i + 1 # count in human pls
          new_path = path + n

          ref = ref_array[i]
          can = can_array[i]

          case
          when ref_array.length < n ; record_diff ref, can, new_path, :extra
          when can_array.length < n ; record_diff ref, can, new_path, :missing
          else
            compare ref, can, new_path
          end
        end
      end

      def compare_hashes(ref_hash, can_hash, path)
        record_missing_keys ref_hash, can_hash, path
        compare_common_keys ref_hash, can_hash, path
        record_extra_keys   ref_hash, can_hash, path
      end

        def record_missing_keys(ref_hash, can_hash, path)
          keys = ref_hash.keys - can_hash.keys
          keys.each do |k|
            record_diff ref_hash[k], nil, path + k, :missing
          end
        end

        def compare_common_keys(ref_hash, can_hash, path)
          keys = ref_hash.keys & can_hash.keys
          keys.each do |k|
            compare ref_hash[k], can_hash[k], path + k
          end
        end

        def record_extra_keys(ref_hash, can_hash, path)
          keys = can_hash.keys - ref_hash.keys
          keys.each do |k|
            record_diff nil, can_hash[k], path + k, :extra
          end
        end

      def compare_others(ref, can, path)
        return if ref == can
        record_diff ref, can, path, :mismatch
      end

    def record_diff(ref, can, path, type)
      diff = Diff.new(type, path, ref, can)
      diffs << diff
    end
  end

end
