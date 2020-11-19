module CheckPlease

  class Diff
    COLUMNS = %i[ type path reference candidate ]

    attr_reader :type, :reference, :candidate, :path
    def initialize(type, reference, candidate, path)
      @type      = type
      @reference = reference
      @candidate = candidate
      @path      = path.to_s
    end

    def attributes
      Hash[ COLUMNS.map { |name| [ name, send(name) ] } ]
    end

    def inspect
      s = "<"
      s << self.class.name
      s << " type=#{type}"
      s << " path=#{path}"
      s << " ref=#{reference.inspect}"
      s << " can=#{candidate.inspect}"
      s << ">"
      s
    end
  end

end
