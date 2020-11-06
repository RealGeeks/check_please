module CheckPlease
module Printers

  class Base
    def self.render(diffs)
      new(diffs).to_s
    end

    def initialize(diffs)
      @diffs = diffs
    end

    private

    attr_reader :diffs

    def build_string
      io = StringIO.new
      yield io
      io.string.strip
    end
  end

end
end
