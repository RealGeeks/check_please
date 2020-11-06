module CheckPlease
module Printers

  class Base
    def self.render(diffs)
      new(diffs).to_s
    end

    def initialize(diffs)
      @diffs = diffs
    end
  end

end
end
