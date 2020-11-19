require 'table_print'

module CheckPlease
module Printers

  class TablePrint < Base
    InspectStrings = Object.new.tap do |obj|
      def obj.format(value)
        value.is_a?(String) ? value.inspect : value
      end
    end

    PATH_MAX_WIDTH = 250 # if you hit this limit, you have other problems

    TP_OPTS = [
      { type:      { display_name: "Type" } },
      { path:      { display_name: "Path",      width: PATH_MAX_WIDTH } },
      { reference: { display_name: "Reference", formatters: [ InspectStrings ] } },
      { candidate: { display_name: "Candidate", formatters: [ InspectStrings ] } },
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
