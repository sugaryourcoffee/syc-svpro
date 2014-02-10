require_relative 'row_filter'

module Sycsvpro

  class Calculator

    attr_reader :infile, :outfile, :row_filter, :formulae, :header

    def initialize(options={})
      puts options.inspect
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @row_filter = RowFilter.new(options[:rows])
      @header     = options[:header]
      @formulae   = {}
      create_calculator(options[:cols])
    end

    def execute
      File.open(outfile, 'w') do |out|
        File.open(infile).each_with_index do |line, index|
          next if row_filter.process(line, row: index).nil?
          columns = line.chomp.split(';')
          formulae.each do |col, formula|
            columns[col.to_i] = eval(formula.gsub('c', 'columns'))
          end
          out.puts columns.join(';')
        end
      end
    end

    private

      # given a csv file with a;b;c
      # code is in the form of
      # 1:*2,2:*c3-1,4:c1+1
      # 1:*2 means multiply value from column 1 by 2 and assign it to column 1
      # 2:*c3-1 means multiply value from column 2 with value from column 3, subtract 1 and assign
      # the result to column 2
      # 4:c1+1 means create a new column and assign to it the result of the sum of the value of 
      # column 1 + 1
      def create_calculator(code)
        code.split(',').each do |operation|
          col, term = operation.split(':')
          formulae[col] = "c[#{col}].to_f#{term}"
        end
      end

  end

end
