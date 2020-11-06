require 'table_print'
require 'json'

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

    class JSON < Base
      def to_s
        # rows = @diffs.map { |diff| diff_hash(diff) }
        # ::JSON.pretty_generate(rows)

        io = StringIO.new

        io.puts "["
        lines = @diffs.map { |diff| "  " + diff_json(diff) }
        io.puts lines.join(",\n")
        io.puts "]"

        io.string
      end

      private

      def diff_hash(diff)
        Hash[
          Diff::CANONICAL_ORDER.map { |attr_name|
            [ attr_name, diff.send(attr_name) ]
          }
        ]
      end

      def diff_json(diff)
        h = diff_hash(diff)
        json = ::JSON.pretty_generate(h)
        json.gsub(/\n\s*/, " ")
      end
    end
  end

  module Printers
    FORMATS = {
      table: Printers::TablePrint,
      json:  Printers::JSON,
    }
    DEFAULT_FORMAT = :table

    def self.render(diffs, format)
      format ||= DEFAULT_FORMAT
      printer = FORMATS[format]
      printer.render(diffs)
    end
  end

end
