require_relative 'row_filter'
require_relative 'column_filter'

module Sycsvpro

  class Collector
    
    attr_reader :infile, :outfile, :row_filter, :col_filter, :collection

    def initialize(options={})
      @infile = options[:infile]
      @outfile = options[:outfile]
      @row_filter = RowFilter.new(options[:rows])
      @col_filter = ColumnFilter.new(options[:cols])
      @collection = []
    end

    def execute
      File.new(infile).each_with_index do |line, index|
        result = col_filter.process(row_filter.process(line, row: index))
        next if result.nil? or result.chomp.empty?
        result.chomp.split(';').each do |value|
          collection << value.chomp if collection.index(value.chomp).nil?
        end
      end

      File.open(outfile, 'w') do |out|
        collection.sort.each { |c| out.puts c }
      end
    end
  end

end
