module CheckPlease

  module Comparison
    extend self

    def perform(reference, candidate)
      root = CheckPlease::Path.new
      diffs = Diffs.new
      compare reference, candidate, root, diffs
      diffs
    end

    private

    def compare(ref, can, path, diffs)
      case types(ref, can)
      when [ :array, :array ] ; compare_arrays ref, can, path, diffs
      when [ :hash,  :hash  ] ; compare_hashes ref, can, path, diffs
      when [ :other, :other ] ; compare_others ref, can, path, diffs
      else
        diffs.record ref, can, path, :type_mismatch
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

      def compare_arrays(ref_array, can_array, path, diffs)
        max_len = [ ref_array, can_array ].map(&:length).max
        (0...max_len).each do |i|
          n = i + 1 # count in human pls
          new_path = path + n

          ref = ref_array[i]
          can = can_array[i]

          case
          when ref_array.length < n ; diffs.record ref, can, new_path, :extra
          when can_array.length < n ; diffs.record ref, can, new_path, :missing
          else                      ; compare ref, can, new_path, diffs
          end
        end
      end

      def compare_hashes(ref_hash, can_hash, path, diffs)
        record_missing_keys ref_hash, can_hash, path, diffs
        compare_common_keys ref_hash, can_hash, path, diffs
        record_extra_keys   ref_hash, can_hash, path, diffs
      end

        def record_missing_keys(ref_hash, can_hash, path, diffs)
          keys = ref_hash.keys - can_hash.keys
          keys.each do |k|
            diffs.record ref_hash[k], nil, path + k, :missing
          end
        end

        def compare_common_keys(ref_hash, can_hash, path, diffs)
          keys = ref_hash.keys & can_hash.keys
          keys.each do |k|
            compare ref_hash[k], can_hash[k], path + k, diffs
          end
        end

        def record_extra_keys(ref_hash, can_hash, path, diffs)
          keys = can_hash.keys - ref_hash.keys
          keys.each do |k|
            diffs.record nil, can_hash[k], path + k, :extra
          end
        end

      def compare_others(ref, can, path, diffs)
        return if ref == can
        diffs.record ref, can, path, :mismatch
      end
  end

end
