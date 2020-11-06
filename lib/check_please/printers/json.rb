require 'json'

module CheckPlease
module Printers

  class JSON < Base
    def to_s
      return "[]" if @diffs.empty?

      build_string do |io|
        io.puts "["
        io.puts @diffs.map { |diff| "  " + diff_json(diff) }.join(",\n")
        io.puts "]"
      end
    end

    private

    def diff_json(diff)
      h = Hash[ Diff::COLUMNS.map { |name| [ name, diff.send(name) ] } ]
      json = ::JSON.pretty_generate(h)
      json.gsub(/\n\s*/, " ")
    end
  end

end
end
