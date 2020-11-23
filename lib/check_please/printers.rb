module CheckPlease

  module Printers
    autoload :Base,       "check_please/printers/base"
    autoload :JSON,       "check_please/printers/json"
    autoload :TablePrint, "check_please/printers/table_print"

    PRINTERS_BY_FORMAT = {
      table: Printers::TablePrint,
      json:  Printers::JSON,
    }
    FORMATS = PRINTERS_BY_FORMAT.keys.sort
    DEFAULT_FORMAT = :table

    def self.render(diffs, flags = {})
      flags = CheckPlease::Flags.new(flags)
      printer = PRINTERS_BY_FORMAT[flags.format]
      printer.render(diffs)
    end
  end

end
