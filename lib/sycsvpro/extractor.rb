require_relative 'row_filter'
require_relative 'column_filter'

module Sycsvpro

  class Extractor

    attr_reader :in_file, :out_file, :row_filter, :col_filter

    def initialize(in_file, out_file, rows, cols)
      @in_file  = in_file
      @out_file = out_file
      @row_filter = RowFilter.new(rows)
      @col_filter = ColumnFilter.new(cols)
    end

    def extract
      File.open(out_file, 'w') do |o|
        File.new(in_file, 'r').each_with_index do |line, index|
          extraction = col_filter.process(row_filter.process(line.chomp, row: index))
          o.puts extraction unless extraction.nil?
        end
      end
    end

  end

end
