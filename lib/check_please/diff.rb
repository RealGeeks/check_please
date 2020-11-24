module CheckPlease

  class Diff
    COLUMNS = %i[ type path reference candidate ]

    attr_reader(*COLUMNS)
    def initialize(type, path, reference, candidate)
      @type      = type
      @path      = path.to_s
      @reference = reference
      @candidate = candidate
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
