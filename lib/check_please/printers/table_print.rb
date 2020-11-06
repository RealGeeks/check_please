require 'table_print'

module CheckPlease
module Printers

  class TablePrint < Base
    TP_CONFIG = ::TablePrint::Config
    COLS      = Diff::CANONICAL_ORDER

    def to_s
      old_io = TP_CONFIG.io
      io = StringIO.new
      TP_CONFIG.io = io

      tp @diffs.to_a, *COLS

      lines = io.string.lines

      return lines.map(&:rstrip).join("\n")

    ensure
      TP_CONFIG.io = old_io
    end
  end

end
end
