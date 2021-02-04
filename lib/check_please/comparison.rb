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

      case types_for_compare(ref, can)
      when [ :array, :array ] ; compare_arrays ref, can, path
      when [ :hash,  :hash  ] ; compare_hashes ref, can, path
      when [ :other, :other ] ; compare_others ref, can, path
      else
        record_diff ref, can, path, :type_mismatch
      end
    end

      def types_for_compare(*list)
        list.map { |e|
          case e
          when Array ; :array
          when Hash  ; :hash
          else       ; :other
          end
        }
      end

      def compare_arrays(ref_array, can_array, path)
        case
        when ( key = path.key_to_match_by(flags) )
          compare_arrays_by_key ref_array, can_array, path, key
        when path.match_by_value?(flags)
          compare_arrays_by_value ref_array, can_array, path
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

              if flags.indifferent_keys
                h = stringify_symbol_keys(h)
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

        # FIXME: this can generate duplicate paths.
        # Time to introduce lft_path, rgt_path ?
        def compare_arrays_by_value(ref_array, can_array, path)
          assert_can_match_by_value! ref_array
          assert_can_match_by_value! can_array

          matches = can_array.map { false }

          # Look for missing values
          ref_array.each.with_index do |ref, i|
            new_path = path + (i+1) # count in human pls

            # Weird, but necessary to handle duplicates properly
            j = can_array.index.with_index { |can, j|
              matches[j] == false && can == ref
            }

            if j
              matches[j] = true
            else
              record_diff ref, nil, new_path, :missing
            end
          end

          # Look for extra values
          can_array.zip(matches).each.with_index do |(can, match), i|
            next if match
            new_path = path + (i+1) # count in human pls
            record_diff nil, can, new_path, :extra
          end
        end

          def assert_can_match_by_value!(array)
            if array.any? { |e| Array === e || Hash === e }
              raise CheckPlease::BehaviorUndefined,
                "match_by_value behavior is not defined for collections!"
            end
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
        if flags.indifferent_keys
          ref_hash = stringify_symbol_keys(ref_hash)
          can_hash = stringify_symbol_keys(can_hash)
        end
        record_missing_keys ref_hash, can_hash, path
        compare_common_keys ref_hash, can_hash, path
        record_extra_keys   ref_hash, can_hash, path
      end

        def stringify_symbol_keys(h)
          Hash[
            h.map { |k,v|
              [ stringify_symbol(k), v ]
            }
          ]
        end

          def stringify_symbol(x)
            Symbol === x ? x.to_s : x
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
        if flags.indifferent_values
          ref = stringify_symbol(ref)
          can = stringify_symbol(can)
        end
        return if ref == can
        record_diff ref, can, path, :mismatch
      end

    def record_diff(ref, can, path, type)
      diff = Diff.new(type, path, ref, can)
      diffs << diff
    end
  end

end
