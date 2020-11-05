require 'forwardable'

module CheckPlease

  # Custom collection class for Diff instances.
  # Can retrieve members using indexes or paths.
  class Diffs
    def initialize
      @list = []
      @hash = {}
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
      @list << diff
      @hash[diff.path] = diff
    end

    def record(ref, can, path, type)
      self << Diff.new(type, ref, can, path)
    end

    def length
      @list.length
    end
  end

end
