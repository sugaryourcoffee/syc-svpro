require_relative 'row_filter'
require_relative 'column_filter'

module Sycsvpro

  class Extractor

    attr_reader :in_file, :out_file, :row_filter, :col_filter

    def initialize(options={})
      @in_file  = options[:infile]
      @out_file = options[:outfile]
      @row_filter = RowFilter.new(options[:rows])
      @col_filter = ColumnFilter.new(options[:cols])
    end

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
