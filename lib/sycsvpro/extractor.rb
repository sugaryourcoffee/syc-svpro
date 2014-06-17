require_relative 'row_filter'
require_relative 'column_filter'

# Operating csv files
module Sycsvpro

  # Extracts rows and columns from a csv file
  class Extractor

    # infile contains the data that is operated on
    attr_reader :in_file
    # outfile is the file where the result is written to
    attr_reader :out_file
    # filter that is used for rows
    attr_reader :row_filter
    # filter that is used for columns
    attr_reader :col_filter

    # Creates a new extractor
    def initialize(options={})
      @in_file  = options[:infile]
      @out_file = options[:outfile]
      @row_filter = RowFilter.new(options[:rows], df: options[:df])
      @col_filter = ColumnFilter.new(options[:cols], df: options[:df])
    end

    # Executes the extractor
    def execute
      File.open(out_file, 'w') do |o|
        File.new(in_file, 'r').each_with_index do |line, index|
          extraction = col_filter.process(row_filter.process(line.chomp, row: index))
          o.puts extraction unless extraction.nil?
        end
      end
    end

  end

end
