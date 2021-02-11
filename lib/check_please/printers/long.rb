module CheckPlease
module Printers

  class Long < Base
    def to_s
      return "" if diffs.empty?

      out = build_string do |io|
        diffs.each do |diff|
          t = diff.type.to_sym
          ref, can = *[ diff.reference, diff.candidate ].map(&:inspect)
          diff_string = <<~EOF.strip
            #{diff.path} [#{diff.type}]
              reference: #{( t == :extra   ) ? "[no value]" : ref}
              candidate: #{( t == :missing ) ? "[no value]" : can}
          EOF

          io.puts diff_string
          io.puts
        end
      end

      out.strip
    end

    private
  end

end
end

