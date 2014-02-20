require_relative 'row_filter'
require_relative 'column_filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # Creates a new counter that counts values and uses the values as column names and uses the count
  # as the column value
  class Counter

    include Dsl

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
    attr_reader :key_values
    # header of the out file
    attr_reader :heading
    # Title of the sum row
    attr_reader :sum_title
    # row where to add the sums of the columns of the sum columns
    attr_reader :sum_row
    # sums of the column values
    attr_reader :sums
    
    # Creates a new counter
    def initialize(options={})
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @key_column = options[:key].to_i
      @row_filter = RowFilter.new(options[:rows])
      @col_filter = ColumnFilter.new(options[:cols], df: options[:df])
      @key_values = {}
      @heading    = []
      @sum_title, @sum_row = options[:sum].split(':') unless options[:sum].nil?
      @sum_row    = @sum_row.to_i unless @sum_row.nil?
      @sums       = Hash.new(0)
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
          key = unstring(line).split(';')[key_column]
          key_value = key_values[key] || key_values[key] = { name: key, elements: Hash.new(0) }
          result.chomp.split(';').each do |column|
            heading << column if heading.index(column).nil?
            key_value[:elements][column] += 1
            sums[column] += 1
          end
        end
      end
    end

    # Writes the results
    def write_result
      sum_line = [sum_title]
      heading.sort.each do |h|
        sum_line << sums[h]
      end
      row = 0;
      File.open(outfile, 'w') do |out|
        out.puts sum_line.join(';') if row == sum_row
        row += 1
        out.puts (["key"] + heading.sort).join(';')
        key_values.each do |k,v|
          out.puts sum_line.join(';') if row == sum_row
          row += 1
          line = [k]
          heading.sort.each do |h|
            line << v[:elements][h]
          end
          out.puts line.join(';')
        end
      end
    end

  end

end
