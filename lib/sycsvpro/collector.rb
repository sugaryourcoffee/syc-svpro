require_relative 'row_filter'
require_relative 'column_filter'

module Sycsvpro

  class Collector
    
    attr_reader :infile, :outfile, :row_filter, :collection

    def initialize(options={})
      @infile = options[:infile]
      @outfile = options[:outfile]
      @row_filter = RowFilter.new(options[:rows])
      @collection = {}
      init_collection(options[:cols])
    end

    def execute
      File.new(infile).each_with_index do |line, index|
        row = row_filter.process(line, row: index)
        next if row.nil? or row.chomp.empty?
        collection.each do |category, elements|
          values = elements[:filter].process(row) 
          values.chomp.split(';').each do |value|
            elements[:entries] << value.chomp if elements[:entries].index(value.chomp).nil?
          end
        end
      end

      File.open(outfile, 'w') do |out|
        collection.each do |category, elements|
          out.puts "[#{category}]"
          elements[:entries].sort.each { |c| out.puts c }
        end
      end
    end

    private

      def init_collection(column_filter)
        column_filter.split('+').each do |f|
          category, filter = f.split(':')
          collection[category] = { entries: [], filter: ColumnFilter.new(filter) }
        end 
      end
  end

end
