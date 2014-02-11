require_relative 'row_filter'
require_relative 'header'

module Sycsvpro

  class Calculator

    attr_reader :infile, :outfile, :row_filter, :formulae, :header, :columns

    def initialize(options={})
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @row_filter = RowFilter.new(options[:rows])
      @header     = Header.new(options[:header])
      @formulae   = {}
      create_calculator(options[:cols])
    end

    def method_missing(id, *args, &block)
      to_number(columns[$1.to_i]) if id =~ /c(\d+)/
    end

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

          @columns = line.chomp.split(';')
          formulae.each do |col, formula|
            @columns[col.to_i] = eval(formula)
          end
          out.puts @columns.join(';')
        end
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

      def to_number(value)
        return value.to_i unless value =~ /\./
        return value.to_f if     value =~ /\./ 
      end

  end

end
