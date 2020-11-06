require 'forwardable'

module CheckPlease

  # Custom collection class for Diff instances.
  # Can retrieve members using indexes or paths.
  class Diffs
    def initialize(diff_list = nil)
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
      @list << diff
      @hash[diff.path] = diff
    end

    def record(ref, can, path, type)
      self << Diff.new(type, ref, can, path)
    end

    extend Forwardable
    def_delegators :@list, *%i[
      each
      length
      map
      to_a
    ]
  end

end
