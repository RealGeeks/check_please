require 'table_print'

module CheckPlease
module Printers

  class TablePrint < Base
    TP_OPTS = [
      :type,
      { :path => { width: 250 } }, # if you hit this limit, you have other problems
      :reference,
      :candidate,
    ]

    def to_s
      return "" if diffs.empty?

      out = build_string do |io|
        switch_tableprint_io(io) do
          tp diffs.data, *TP_OPTS
        end
      end
      strip_trailing_whitespace(out)
    end

    private

    def switch_tableprint_io(new_io)
      config = ::TablePrint::Config
      @old_io = config.io
      config.io = new_io
      yield
    ensure
      config.io = @old_io
    end

    def strip_trailing_whitespace(s)
      s.lines.map(&:rstrip).join("\n")
    end
  end

end
end
