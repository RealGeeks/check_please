module CheckPlease
module Printers

  class JSON < Base
    def to_s
      return "[]" if diffs.empty?

      build_string do |io|
        io.puts "["
        io.puts diffs.map { |diff| diff_json(diff) }.join(",\n")
        io.puts "]"
      end
    end

    private

    def diff_json(diff, prefix = "  ")
      h = diff.attributes
      json = ::JSON.pretty_generate(h)
      prefix.to_s + json.gsub(/\n\s*/, " ")
    end
  end

end
end
