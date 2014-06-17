require_relative 'row_filter'
require_relative 'column_filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # Counter counts values and uses the values as column names and uses the count
  # as the column value
  class Counter

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # values are assigned to the key columns
    attr_reader :key_columns
    # key columns headers
    attr_reader :key_titles
    # filter that is used for rows
    attr_reader :row_filter
    # filter that is used for columns
    attr_reader :col_filter
    # values that are assigned to the key column 
    attr_reader :key_values
    # header of the out file
    attr_reader :heading
    # indicates whether the headline values should be sorted
    attr_reader :heading_sort
    # Title of the sum row
    attr_reader :sum_row_title
    # row where to add the sums of the columns
    attr_reader :sum_row
    # Title of the sum column
    attr_reader :sum_col_title
    # sums of the column values
    attr_reader :sums
    
    # Creates a new counter. Takes as attributes infile, outfile, key, rows, cols, date-format and
    # indicator whether to add a sum row
    def initialize(options={})
      @infile       = options[:infile]
      @outfile      = options[:outfile]
      init_key_columns(options[:key])
      @row_filter   = RowFilter.new(options[:rows], df: options[:df])
      @col_filter   = ColumnFilter.new(options[:cols], df: options[:df])
      @key_values   = {}
      @heading      = []
      @heading_sort = options[:sort].nil? ? true : options[:sort]
      init_sum_scheme(options[:sum])
      @sums         = Hash.new(0)
    end

    # Executes the counter
    def execute
      process_count
      write_result
    end

    # Processes the counting on the in file
    def process_count
      File.new(infile).each_with_index do |line, index|
        result = col_filter.process(row_filter.process(line.chomp, row: index))
        unless result.nil? or result.empty?
          key = unstring(line).split(';').values_at(*key_columns)
          key_value = key_values[key] || key_values[key] = { name: key, 
                                                             elements: Hash.new(0), 
                                                             sum: 0 }
          result.chomp.split(';').each do |column|
            heading << column if heading.index(column).nil?
            key_value[:elements][column] += 1
            key_value[:sum] += 1
            sums[column] += 1
          end
        end
      end
      unless sum_col_title.nil?
        heading << sum_col_title
        sums[sum_col_title] = sums.values.inject(:+)
      end
    end

   # Writes the count results
    def write_result
      sum_line = [sum_row_title] + [''] * (key_titles.size - 1)
      headline = heading_sort ? heading.sort : col_filter.pivot.keys
      headline.each do |h|
        sum_line << sums[h]
      end
      row = 0;
      File.open(outfile, 'w') do |out|
        out.puts sum_line.join(';') if row == sum_row ; row += 1
        out.puts (key_titles + headline).join(';')
        key_values.each do |k,v|
          out.puts sum_line.join(';') if row == sum_row ; row += 1
          line = [k]
          headline.each do |h|
            line << v[:elements][h] unless h == sum_col_title
          end
          line << v[:sum] unless sum_col_title.nil?
          out.puts line.join(';')
        end
      end
    end

    private

      # Initializes the sum row title an positions as well as the cum column title
      def init_sum_scheme(sum_scheme)

        return if sum_scheme.nil?

        re = /(\w+):(\d+)|(\w+)/

        sum_scheme.scan(re).each do |part|
          if part.compact.size == 2
            @sum_row_title = part[0]
            @sum_row       = part[1].to_i
          else
            @sum_col_title = part[2]
          end
        end

      end

      # Initialize the key columns and headers
      def init_key_columns(key_scheme)

        @key_titles  = []
        @key_columns = []

        keys = key_scheme.scan(/(\d+):(\w+)/)

        keys.each do |key|
          @key_titles  << key[1]
          @key_columns << key[0].to_i
        end

      end

  end

end
