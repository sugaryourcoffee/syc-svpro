require_relative 'row_filter'
require_relative 'header'
require_relative 'dsl'
require 'date'

# Operating csv files
module Sycsvpro

  # Extracts values from a csv file and enables to associate values to key
  # values. Columns can be created dynamically based on the content of columns.
  # Example:
  # File 1 (infile)
  #     Date       | Order-Type | Revenue
  #     01.01.2013 | AZ         | 22.50
  #     13.04.2014 | BZ         | 33.40
  #     16.12.2014 | CZ         | 12.80
  #
  # File 2 (outfile)
  #     Year | AZ    | BZ    | CZ    | Total
  #     2013 | 22.50 |       |       | 22.50
  #     2014 |       | 33.40 | 12.80 | 46.20
  class Table

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # filter that is used for rows
    attr_reader :row_filter
    # date format for date operations
    attr_reader :date_format
    # header of the outfile
    attr_reader :header
    # rows of the created table
    attr_reader :rows

    # Creates a new Table. Options expects :infile, :outfile, :rows and 
    # :columns. Optionally a header can be provided. The header can be 
    # supplemented with additional column names that are generated due to a 
    # arithmetic operation that creates new columns
    # :call-seq:
    #   Sycsvpro::Table.new(infile:  "in.csv",
    #                       outfile: "out.csv",
    #                       df:      "%d.%m.%Y",
    #                       rows:    "1,2,BEGINn3>20END",
    #                       header:  "Year,c6,c1",
    #                       key:     "c0=~/\\.(\\d{4})/,c6",
    #                       cols:    "Value:+n1,c2+c3:+n1",
    #                       nf:      "DE",
    #                       pr:      "2",
    #                       sum:     "TOP:Value,c2+c3",
    #                       sort:    "2").execute
    #
    # infile:: csv file to operate on
    # outfile:: csv file with the result
    # df:: date format
    # nf:: number format of number values. "DE" e.g. is 1.000,00 where as 
    #      US is 1,000.00
    # pr:: precision of number values. 
    # rows:: rows to consider for operation. Rows that don't match the pattern
    #        will be skipped for operation
    # header:: Header of the csv file
    # key:: Values located at value 0 and subsequent columns
    # cols:: Values added to columns base on a operation or assignment
    # sum:: sum row at specified position top or eof
    # sort:: indicates that the columns have to sorted from index on
    def initialize(options = {})
      @infile      = options[:infile]
      @outfile     = options[:outfile]
      @date_format = options[:df] || "%Y-%m-%d"
      @row_filter  = RowFilter.new(options[:rows], df: options[:df])
      @header      = Header.new(options[:header], sort: options[:sort])
      @keys        = split_by_comma_regex(options[:key])
      @cols        = split_by_comma_regex(options[:cols])
      @number_format = options[:nf] || 'EN'
      @precision     = options[:pr].to_i if options[:pr]
      prepare_sum_row options[:sum]
      @sort          = options[:sort]
      @rows        = {}
    end

    # Retrieves the values from a row as the result of a arithmetic operation
    # with #eval. It reconizes
    # c:: string value
    # n:: number value
    # d:: date value
    def method_missing(id, *args, &block)
      return @columns[$1.to_i]            if id =~ /c(\d+)/
      return to_number(@columns[$1.to_i]) if id =~ /n(\d+)/
      return to_date(@columns[$1.to_i])   if id =~ /d(\d+)/
      super
    end

    # Executes the table and writes the result to the _outfile_
    def execute
      create_table_data
      write_to_file
    end

    # Create the table
    def create_table_data
      processed_header = false

      File.open(infile).each_with_index do |line, index|
        line = line.chomp

        next if line.empty?
        
        line = unstring(line).chomp

        header.process line, processed_header

        unless processed_header
          processed_header = true
          next
        end

        next if row_filter.process(line, row: index).nil?
        
        @columns = line.split(';')

        create_row(create_key, line)
      end

    end

    # Write table to _outfile_
    def write_to_file
      File.open(outfile, 'w') do |out|
        out.puts header.to_s
        out.puts create_sum_row if @sum_row_pos == 'TOP'
        rows.each do |key, row|
          line = [] << row[:key]
          header.clear_header_cols.each_with_index do |col, index|
            next if index < row[:key].size
            line << row[:cols][col]
          end
          out.puts line.flatten.join(';')
        end
        out.puts create_sum_row if @sum_row_pos == 'EOF'
      end
    end

    # Creates a key from the provided key pattern
    def create_key
      key = []
      @keys.each { |k| key << evaluate(k, "") }
      key
    end

    # Creates a table row based on the column pattern
    # Examples of column patterns
    # * Value:+n1             Adds content of column 1 to Value column
    # * Value:+n1,c2+c3:+n1   Creates a dynamic column and adds column 1 value
    # * c0=~/\\.(\\d{4})/:+n1 Creates dynamic column from regex and adds
    #                         column 1 value
    def create_row(key, line)
      row = rows[key] || rows[key] = { key: key, cols: Hash.new(0) }  
      @cols.each do |col|
        column, formula = col.split(':')
        column = evaluate(column) if column =~ /^\(?c\d+[=~+.]/
        previous_value = row[:cols][column]
        if value = eval("#{row[:cols][column]}#{formula}")
          row[:cols][column] = @precision ? value.round(@precision) : value
          add_to_sum_row(row[:cols][column] - previous_value, column)
        end
      end
    end

    private

      # Casts a string to an integer or float depending whether the value has a 
      # decimal point
      def to_number(value)
        value = convert_to_en(value)
        return value.to_i unless value =~ /\./
        return value.to_f if     value =~ /\./ 
      end

      # Casts a string to a date
      def to_date(value)
        if value.nil? or value.strip.empty?
          nil
        else
          Date.strptime(value, date_format)
        end
      end

      # Localize the number to EN
      def convert_to_en(value)
        if @number_format == 'DE'
          value.gsub('.', '_').gsub(',', '.')
        else
          value
        end
      end

      # Evaluate a formula
      # Example invokation
      #     evaluate("n1+n2", 0)
      #     evaluate("c1+c2", "failed")
      #     evaluate("c0=~/\\.(\\d{4})/", "0")
      def evaluate(formula, fail_result = 0)
        if value = eval(formula)
          last_match = $1
          (formula =~ /^c\(?\d+=~/) ? last_match : value
        else
          fail_result
        end   
      end

      # Initializes sum_row_pos, sum_row and sum_row_patterns based on the
      # provided sum option
      def prepare_sum_row(pattern)
        return if pattern.nil? || pattern.empty?
        @sum_row_pos, sum_row_pattern = pattern.split(/(?<=^top|^eof):/i)
        @sum_row_pos.upcase!
        @sum_row = Hash.new
        @sum_row_patterns = split_by_comma_regex(sum_row_pattern)
      end

      # Adds a value in the specified column to the sum_row
      def add_to_sum_row(value, column)
        return unless @sum_row_patterns
        @sum_row_patterns.each do |pattern|
          if pattern =~ /^\(?c\d+[=~+.]/
            header_column = evaluate(pattern, "")
          else
            header_column = pattern
          end

          if header_column == column
            @sum_row[header_column] ||= 0
            @sum_row[header_column] += value
          end
        end
      end

      # Creates the sum_row when the file has been completely processed
      def create_sum_row
        line = []
        header.clear_header_cols.each do |col|
          line << @sum_row[col] || ""
        end
        line.flatten.join(';')
      end

  end

end

