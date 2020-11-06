require 'table_print'

module CheckPlease
module Printers

  class TablePrint < Base
    def to_s
      build_string do |io|
        switch_tableprint_io(io) do
          tp @diffs.to_a, *Diff::COLUMNS
        end
      end
    end

    private

    TP_CONFIG = ::TablePrint::Config

    def switch_tableprint_io(new_io)
      @old_io = TP_CONFIG.io
      TP_CONFIG.io = new_io
      yield
    ensure
      TP_CONFIG.io = @old_io
    end
  end

end
end
