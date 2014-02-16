require_relative 'row_filter'
require_relative 'column_filter'

# Operating csv files
module Sycsvpro

  # Creates a new counter that counts values and uses the values as column names and uses the count
  # as the column value
  class Counter

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # values are assigned to the key column
    attr_reader :key_column
    # filter that is used for rows
    attr_reader :row_filter
    # filter that is used for columns
    attr_reader :col_filter
    # values that are assigned to the key column 
    attr_reader :customers
    # header of the out file
    attr_reader :heading
    
    # Creates a new counter
    def initialize(options={})
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @key_column = options[:key].to_i
      @row_filter = RowFilter.new(options[:rows])
      @col_filter = ColumnFilter.new(options[:cols], df: options[:df])
      @customers  = {}
      @heading    = []
    end

    # Executes the counter
    def execute
      process_file
      write_result
    end

    # Processes the counting on the in file
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

    # Writes the results
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
