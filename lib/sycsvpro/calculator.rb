require_relative 'row_filter'
require_relative 'header'
require_relative 'dsl'
require 'date'

# Operating csv files
module Sycsvpro

  # Processes arithmetic operations on columns of a csv file. A column value has to be a number.
  # Possible operations are +, -, * and /. It is also possible to use values of columns as an
  # operator like c1*2 will multiply the value of column 1 with 2.
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
    # filter that is used for columns
    attr_reader :columns
    # if true add a sum row at the bottom of the out file
    attr_reader :add_sum_row

    # Creates a new Calculator. Options expects :infile, :outfile, :rows and 
    # :columns. Optionally a header can be provided. The header can be 
    # supplemented with additional column names that are generated due to a 
    # arithmetic operation that creates new columns
    # :call-seq:
    #   Sycsvpro::Calculator.new(infile:  "in.csv",
    #                            outfile: "out.csv",
    #                            df:      "%d.%m.%Y",
    #                            rows:    "1,2,BEGINn3>20END",
    #                            header:  "*,Count",
    #                            cols:    "4:Count=c1+c2*2",
    #                            sum:     true).execute
    def initialize(options={})
      @infile      = options[:infile]
      @outfile     = options[:outfile]
      @date_format = options[:df] || "%Y-%m-%d"
      @row_filter  = RowFilter.new(options[:rows], df: options[:df])
      @header      = Header.new(options[:header])
      @sum_row     = []
      @add_sum_row = options[:sum] || false
      @formulae    = {}
      create_calculator(options[:cols])
    end

    # Retrieves the values from a row as the result of a arithmetic operation
    # with #eval
    def method_missing(id, *args, &block)
      return to_number(columns[$1.to_i]) if id =~ /c(\d+)/
      return to_date(columns[$1.to_i])   if id =~ /d(\d+)/
      super
    end

    # Executes the calculator and writes the result to the _outfile_
    def execute
      processed_header = false

      File.open(outfile, 'w') do |out|
        File.open(infile).each_with_index do |line, index|
          next if line.chomp.empty?

          unless processed_header
            header_row = header.process(line.chomp)
            out.puts header_row unless header_row.empty?
            processed_header = true
            next
          end

          next if row_filter.process(line, row: index).nil?

          @columns = unstring(line).chomp.split(';')
          formulae.each do |col, formula|
            @columns[col.to_i] = eval(formula)
          end
          out.puts @columns.join(';')

          @columns.each_with_index do |column, index|
            column = 0 unless column.to_s =~ /^[\d\.,]*$/

            if @sum_row[index]
              @sum_row[index] += to_number column
            else
              @sum_row[index] =  to_number column
            end
          end if add_sum_row

        end

        out.puts @sum_row.join(';') if add_sum_row

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
          col, term = operation.split(':')
          term = "c#{col}#{term}" unless term =~ /^c\d+|^\[/
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
