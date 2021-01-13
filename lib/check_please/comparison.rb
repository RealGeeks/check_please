module CheckPlease
  using Refinements

  class DuplicateKeyError < ::IndexError
    include CheckPlease::Error
  end

  class TypeMismatchError < ::TypeError
    include CheckPlease::Error
  end

  class NoSuchKeyError < ::KeyError
    include CheckPlease::Error
  end

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
        if ( key = path.key_for_compare(flags) )
          compare_arrays_by_key ref_array, can_array, path, key
        else
          compare_arrays_by_index ref_array, can_array, path
        end
      end

        def compare_arrays_by_key(ref_array, can_array, path, key_name)
          refs_by_key = index_array!(ref_array, path, key_name, "reference")
          cans_by_key = index_array!(can_array, path, key_name, "candidate")
          key_values = (refs_by_key.keys | cans_by_key.keys)

          key_values.compact! # NOTE: will break if nil is ever used as a key (but WHO WOULD DO THAT?!)
          key_values.sort!

          key_values.each do |key_value|
            new_path = path + "#{key_name}=#{key_value}"
            ref = refs_by_key[key_value]
            can = cans_by_key[key_value]
            case
            when ref.nil? ; record_diff ref, can, new_path, :extra
            when can.nil? ; record_diff ref, can, new_path, :missing
            else          ; compare ref, can, new_path
            end
          end
        end

          def index_array!(array_of_hashes, path, key_name, ref_or_can)
            elements_by_key = {}

            array_of_hashes.each.with_index do |h, i|
              # make sure we have a hash
              unless h.is_a?(Hash)
                raise CheckPlease::TypeMismatchError, \
                  "The element at position #{i} in the #{ref_or_can} array is not a hash."
              end

              # try to get the value of the attribute identified by key_name
              key_value = h.fetch(key_name) {
                raise CheckPlease::NoSuchKeyError, \
                  <<~EOF
                    The #{ref_or_can} hash at position #{i} has no #{key_name.inspect} key.
                    Keys it does have: #{h.keys.inspect}
                  EOF
              }

              # complain about dupes
              if elements_by_key.has_key?(key_value)
                key_val_expr = "#{key_name}=#{key_value}"
                raise CheckPlease::DuplicateKeyError, \
                  "Duplicate #{ref_or_can} element found at path '#{path + key_val_expr}'."
              end

              # ok, now we can proceed
              elements_by_key[key_value] = h
            end

            elements_by_key
          end

        def compare_arrays_by_index(ref_array, can_array, path)
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
