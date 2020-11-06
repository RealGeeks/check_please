require 'json'

module CheckPlease
module Printers

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
end
