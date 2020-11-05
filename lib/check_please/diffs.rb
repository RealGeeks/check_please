require 'forwardable'

module CheckPlease

  class Diffs
    extend Forwardable
    def_delegators :list, *%i[
      first
      length
    ]

    attr_accessor :reference, :candidate
    def initialize(reference, candidate)
      @reference = reference
      @candidate = candidate
      build_list
    end

    private

    def list
      @_list ||= []
    end

    def build_list
      if reference != candidate
        list << Diff.new(reference, candidate, "/")
      end
    end
  end

end
