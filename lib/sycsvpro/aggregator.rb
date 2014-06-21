require_relative 'row_filter'
require_relative 'column_filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # An Aggregator counts specified row values and adds a sum to the end of 
  # the row
  class Aggregator

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # file doesn't contain a header
    attr_reader :headerless
    # filter that is used for rows
    attr_reader :row_filter
    # filter that is used for columns
    attr_reader :col_filter
    # values that are aggregated
    attr_reader :key_values
    # header of the out file
    attr_reader :heading
    # Title of the sum row
    attr_reader :sum_row_title
    # row where to add the sums of the columns
    attr_reader :sum_row
    # Title of the sum column
    attr_reader :sum_col_title
    # column where to add the sum of the row sum
    attr_reader :sum_col
    # sums of the column values
    attr_reader :sums
    
    # Creates a new aggregator. Takes as attributes infile, outfile, key, rows, 
    # cols, date-format and indicator whether to add a sum row
    # :call-seq:
    #   Sycsvpro::Aggregator.new(infile:     "in.csv",
    #                            outfile:    "out.csv",
    #                            headerless: false,
    #                            rows:       "1,2-4,/\S/"
    #                            cols:       "0,5",
    #                            df:         "%d.%m.%Y",
    #                            sum:        "Total:1,Items").execute
    def initialize(options={})
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @headerless = options[:headerless] || false
      @row_filter = RowFilter.new(options[:rows], df: options[:df])
      @col_filter = ColumnFilter.new(options[:cols], df: options[:df])
      @key_values = Hash.new(0)
      @heading    = []
      @sums       = Hash.new(0)
      init_sum_scheme(options[:sum])
    end

    # Executes the aggregator
    def execute
      process_aggregation
      write_result
    end

    # Process the aggregation of the key values. The result will be written to
    # _outfile_
    def process_aggregation
      File.new(infile).each_with_index do |line, index|
        result = col_filter.process(row_filter.process(line.chomp, row: index))
        unless result.nil? or result.empty?
          if heading.empty? and not headerless
            heading << result.split(';')
            next
          else
            @sum_col = [result.split(';').size, sum_col].max 
          end
          key_values[result]  += 1
          sums[sum_col_title] += 1
        end
      end
      heading.flatten!
      heading[sum_col] = sum_col_title
    end

    # Writes the aggration results
    def write_result
      sum_line = [sum_row_title]
      (heading.size - 2).times { sum_line << "" }
      sum_line << sums[sum_col_title]
      row = 0;
      File.open(outfile, 'w') do |out|
        out.puts sum_line.join(';') if row == sum_row ; row += 1
        out.puts heading.join(';')
        key_values.each do |k, v|
          out.puts sum_line.join(';') if row == sum_row ; row += 1
          out.puts [k, v].join(';')
        end
      end
    end

    private

      # Initializes the sum row title an positions as well as the sum column 
      # title and position
      def init_sum_scheme(sum_scheme)
        row_scheme, col_scheme = sum_scheme.split(',') unless sum_scheme.nil?

        unless row_scheme.nil?
          @sum_row_title, @sum_row = row_scheme.split(':') unless row_scheme.empty?
        end
        
        @sum_row.nil? ? @sum_row = 0 : @sum_row = @sum_row.to_i
        @sum_row_title = 'Total' if @sum_row_title.nil? 

        col_scheme.nil? ? @sum_col_title = 'Total' : @sum_col_title = col_scheme
        @sum_col = 0
      end

  end

end
