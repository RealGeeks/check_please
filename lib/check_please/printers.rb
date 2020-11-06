require_relative 'printers/base'
require_relative 'printers/json'
require_relative 'printers/table_print'

module CheckPlease

  module Printers
    PRINTERS_BY_FORMAT = {
      table: Printers::TablePrint,
      json:  Printers::JSON,
    }
    FORMATS = PRINTERS_BY_FORMAT.keys.sort
    DEFAULT_FORMAT = :table

    def self.render(diffs, format)
      format ||= DEFAULT_FORMAT
      printer = PRINTERS_BY_FORMAT[format.to_sym]
      printer.render(diffs)
    end
  end

end
