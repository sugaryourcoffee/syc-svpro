require_relative 'row_filter'
require_relative 'header'
require_relative 'dsl'
require 'date'

# Operating csv files
module Sycsvpro

  # Processes operations on columns of a csv file. 
  #
  # A column value has to be a number in case of arithmetical operations. 
  #
  # Possible operations are +, -, *, /, % and **. 
  #
  # It is possible to use values of columns as an operator like multiply 
  # column 1 of the csv file with 2 and assign it to column 4 of the result 
  # file: c1*2
  #
  # Other values might be dates or strings.
  #
  # d1:: date value in column 1
  # s2:: string value in column 2
  # c3:: number value in column 3
  #
  # To assign a string from column 1 of the csv file to column 3 of the 
  # resulting file you can do like so: 3:s1
  #
  # You can also use Ruby expressions to assign values: 0:[d1,d2,d3].min - This
  # will assign the least date value from columns 1, 2 and 3 to column 0.
  #
  # Note: If you assign a value to column 1 and subsequently are using column 1
  # in other assignments then column 1 will have the result of a previous
  # operation.
  #
  # Example:
  # Having a row "CA/123456" and you want to have 123456 in column 0
  # of the resulting csv file and CA in column 2. If you conduct following
  # operations it will fail
  #     1:s0.scan(/\/(.+)/).flatten[0]   -> 123456 
  #     2:s0.scan(/([A-Z]+)/).flatten[0] -> nil
  # To achieve the required result you have to change the operational sequence
  # like so
  #     2:s0.scan(/([A-Z]+)/).flatten[0] -> CA
  #     1.so.scan(/\/(.+)/).flatten[0]   -> 123456
  class Calculator

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # filter that is used for rows
    attr_reader :row_filter
    # date format for date operations
    attr_reader :date_format
    # the operations on columns
    attr_reader :formulae
    # header of the outfile
    attr_reader :header
    # indicates whether this header is final and should not be filtered in
    # respect to the columns defined by write
    attr_reader :final_header
    # filter that is used for columns
    attr_reader :columns
    # selected columns to be written to outfile
    attr_reader :write
    # if true add a sum row at the bottom of the out file
    attr_reader :add_sum_row

    # Creates a new Calculator. Optionally a header can be provided. The header 
    # can be supplemented with additional column names that are generated due 
    # to an arithmetic operation that creates new columns
    # :call-seq:
    #   Sycsvpro::Calculator.new(infile:       "in.csv",
    #                            outfile:      "out.csv",
    #                            df:           "%d.%m.%Y",
    #                            rows:         "1,2,BEGINn3>20END",
    #                            header:       "*,Count",
    #                            final_header: false,
    #                            cols:         "4:c1+c2*2",
    #                            write:        "1,3-5",
    #                            sum:          true).execute
    # infile:: File that contains the rows to be operated on
    # outfile:: Result of the operations
    # df:: Date format
    # rows:: Row filter that indicates which rows to consider
    # header:: Header of the columns
    # final_header:: Indicates that if write filters columns the header should
    # not be filtered when written
    # cols:: Operations on the column values
    # write:: Columns that are written to the outfile
    # sum:: Indicate whether to add a sum row
    def initialize(options={})
      @infile       = options[:infile]
      @outfile      = options[:outfile]
      @date_format  = options[:df] || "%Y-%m-%d"
      @row_filter   = RowFilter.new(options[:rows], df: options[:df])
      @write_filter = ColumnFilter.new(options[:write], df: options[:df])
      @header       = Header.new(options[:header])
      @final_header = options[:final_header]
      @sum_row      = []
      @add_sum_row  = options[:sum]
      @formulae     = {}
      create_calculator(options[:cols])
    end

    # Retrieves the values from a row as the result of a arithmetic operation
    # with #eval
    def method_missing(id, *args, &block)
      return to_number(columns[$1.to_i]) if id =~ /c(\d+)/
      return to_date(columns[$1.to_i])   if id =~ /d(\d+)/
      return columns[$1.to_i]            if id =~ /s(\d+)/
      super
    end

    # Executes the calculator and writes the result to the _outfile_
    def execute
      processed_header = false

      File.open(outfile, 'w') do |out|
        File.open(infile).each_with_index do |line, index|
          next if line.chomp.empty? || unstring(line).chomp.split(';').empty?

          unless processed_header
            header_row = header.process(line.chomp)
            header_row = @write_filter.process(header_row) unless @final_header
            out.puts header_row unless header_row.nil? or header_row.empty?
            processed_header = true
            next
          end

          next if row_filter.process(line, row: index).nil?

          @columns = unstring(line).chomp.split(';')
          formulae.each do |col, formula|
            @columns[col.to_i] = eval(formula)
          end
          out.puts @write_filter.process(@columns.join(';'))

          @columns.each_with_index do |column, index|
            column = 0 unless column.to_s =~ /^[\d\.,]*$/

            if @sum_row[index]
              @sum_row[index] += to_number column
            else
              @sum_row[index] =  to_number column
            end
          end if add_sum_row

        end

        out.puts @write_filter.process(@sum_row.join(';')) if add_sum_row

      end
    end

    private

      # given a csv file with a;b;c
      # code is in the form of
      # 1:*2,2:*c3-1,4:c1+1
      # 1:*2 means multiply value from column 1 by 2 and assign it to column 1 c[1] = c[1]*2
      # 2:*c3-1 means multiply value from column 2 with value from column 3, subtract 1 and assign
      # the result to column 2 c[2] = c[2] * c[3] - 1
      # 4:c1+1 means create a new column and assign to it the result of the sum of the value of 
      # column 1 + 1 c[4] = c[1] + 1
      def create_calculator(code)
        code.split(/,(?=\d+:)/).each do |operation|
          col, term = operation.split(':', 2)
          term = "c#{col}#{term}" if term =~ /^[+\-*\/%]/
          formulae[col] = term
        end
      end

      # Casts a string to an integer or float depending whether the value has a 
      # decimal point
      def to_number(value)
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

  end

end
