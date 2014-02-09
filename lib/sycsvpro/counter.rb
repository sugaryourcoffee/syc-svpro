require_relative 'row_filter'
require_relative 'column_filter'

module Sycsvpro

  class Counter

    attr_reader :infile, :outfile, :key_column, :row_filter, :col_filter, :customers, :heading
    
    def initialize(options={})
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @key_column = options[:key].to_i
      @row_filter = RowFilter.new(options[:rows])
      @col_filter = ColumnFilter.new(options[:cols], df: options[:df])
      @customers  = {}
      @heading    = []
    end

    def execute
      process_file
      write_result
    end

    def process_file
      File.new(infile).each_with_index do |line, index|
        result = col_filter.process(row_filter.process(line.chomp, row: index))
        unless result.nil? or result.empty?
          key = line.split(';')[key_column]
          customer = customers[key] || customers[key] = { name: key, products: Hash.new(0) }
          result.chomp.split(';').each do |column|
            heading << column if heading.index(column).nil?
            customer[:products][column] += 1
          end
        end
      end
    end

    def write_result
      File.open(outfile, 'w') do |out|
        out.puts (["customer"] + heading.sort).join(';')
        customers.each do |k,v|
          line = [k]
          heading.sort.each do |h|
            line << v[:products][h]
          end
          out.puts line.join(';')
        end
      end
    end

  end

end
