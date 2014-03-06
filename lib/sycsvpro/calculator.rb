require_relative 'row_filter'
require_relative 'header'
require_relative 'dsl'

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
    # the operations on columns
    attr_reader :formulae
    # header of the outfile
    attr_reader :header
    # filter that is used for columns
    attr_reader :columns
    # if true add a sum row at the bottom of the out file
    attr_reader :add_sum_row

    # Creates a new Calculator. Options expects :infile, :outfile, :rows and :columns. Optionally
    # a header can be provided. The header can be supplemented with additional column names that
    # are generated due to a arithmetic operation that creates new columns
    def initialize(options={})
      @infile      = options[:infile]
      @outfile     = options[:outfile]
      @row_filter  = RowFilter.new(options[:rows])
      @header      = Header.new(options[:header])
      @sum_row     = []
      @add_sum_row = options[:sum] || false
      @formulae    = {}
      create_calculator(options[:cols])
    end

    # Retrieves the values from a row as the result of a arithmetic operation
    def method_missing(id, *args, &block)
      to_number(columns[$1.to_i]) if id =~ /c(\d+)/
    end

    # Executes the calculator
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
        code.split(',').each do |operation|
          col, term = operation.split(':')
          term = "c#{col}#{term}" unless term =~ /^c\d+/
          formulae[col] = term
        end
      end

      # Casts a string to an integer or float depending whether the value has a decimal point
      def to_number(value)
        return value.to_i unless value =~ /\./
        return value.to_f if     value =~ /\./ 
      end

  end

end
