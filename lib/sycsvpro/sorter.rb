require_relative 'row_filter'
require_relative 'column_type_filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # Sorts an input file based on a column sort filter
  class Sorter

    include Dsl

    # file of the data to sort
    attr_reader :infile
    # file to write the sorted data to
    attr_reader :outfile
    # row filter
    attr_reader :row_filter
    # column type filter
    attr_reader :col_type_filter
    # sorted rows
    attr_reader :sorted_rows

    # Creates a Sorter and takes as options infile, outfile, rows, cols including types and a
    # date format for the date columns to sort (optional)
    def initialize(options={})
      @infile          = options[:infile]
      @outfile         = options[:outfile]
      @row_filter      = RowFilter.new(options[:rows])
      @col_type_filter = ColumnTypeFilter.new(options[:cols], df: options[:df])
      @sorted_rows     = []
    end

    # Sorts the data of the infile
    def execute
      rows = File.readlines(infile)

      rows.each_with_index do |line, index|
        filtered = col_type_filter.process(row_filter.process(line, row: index))
        next if filtered.nil?
        sorted_rows << (filtered << index)
      end

      File.open(outfile, 'w') do |out|
        sorted_rows.compact.sort.each do |row|
          out.puts unstring(rows[row.last])
        end
      end
    end

  end

end
