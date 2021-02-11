require 'forwardable'

module CheckPlease
  using Refinements

  # Custom collection class for Diff instances.
  # Can retrieve members using indexes or paths.
  class Diffs
    attr_reader :flags
    def initialize(diff_list = nil, flags: {})
      @flags = Flags(flags)
      @list = []
      @hash = {}
      Array(diff_list).each do |diff|
        self << diff
      end
    end

    # this is probably a terrible idea, but this method:
    # - treats integer keys as array-style positional indexes
    # - treats string keys as path strings and does a hash-like lookup (raising if the path is not found)
    #
    # (In my defense, I only did it to make the tests easier to write.)
    def [](key)
      if key.is_a?(Integer)
        @list[key]
      else
        @hash.fetch(key)
      end
    end

    def <<(diff)
      if flags.fail_fast && length > 0
        throw :max_diffs_reached
      end

      if (n = flags.max_diffs)
        # It seems no one can help me now / I'm in too deep, there's no way out
        throw :max_diffs_reached if length >= n
      end

      @list << diff
      @hash[diff.path] = diff
    end

    def data
      @list.map(&:attributes)
    end

    def filter_by_flags(flags)
      new_list = @list.reject { |diff| Path.new(diff.path).excluded?(flags) }
      self.class.new(new_list, flags: flags)
    end

    def to_s(flags = {})
      CheckPlease::Printers.render(self, flags)
    end

    extend Forwardable
    def_delegators :@list, *%i[
      each
      empty?
      length
      map
      to_a
    ]
  end

end
