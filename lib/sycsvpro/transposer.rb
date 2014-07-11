# Operating csv files
module Sycsvpro

  # Tranposes rows to columns and vice versa
  # 
  # Example
  #
  # infile.csv
  # | Year | SP | RP | Total | SP-O | RP-O | O   |
  # | ---- | -- | -- | ----- | ---- | ---- | --- |
  # |      | 10 | 20 | 30    | 100  | 40   | 140 |
  # | 2008 |  5 | 10 | 15    |  10  | 20   |  10 |
  # | 2009 |  2 |  5 |  5    |  20  | 10   |  30 |
  # | 2010 |  3 |  5 | 10    |  70  | 10   | 100 |
  # 
  # outfile.csv
  # | Year  |     | 2008 | 2009 | 2010 |
  # | ----- | --- | ---- | ---- | ---- |
  # | SP    |  10 |    5 |    5 |    3 |
  # | RP    |  20 |   10 |   10 |    5 |
  # | Total |  30 |   15 |   15 |   10 |
  # | SP-O  | 100 |   10 |   10 |   70 |
  # | RP-O  |  40 |   20 |   20 |   10 |
  # | O     | 140 |   10 |   30 |  100 |
  #
  class Transposer

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # filter that is used for rows
    attr_reader :row_filter
    # filter that is used for columns
    attr_reader :col_filter
 
    # Create a new Transpose
    # :call-seq:
    #   Sycsvpro::Transpose(infile:  "infile.csv",
    #                       outfile: "outfile.csv",
    #                       rows:    "0,3-5",
    #                       cols:    "1,3").execute
    def initialize(options = {})
      @infile  = options[:infile]
      @outfile = options[:outfile]
      @row_filter = RowFilter.new(options[:rows])
      @col_filter = ColumnFilter.new(options[:cols])
    end

    # Executes the transpose by reading the infile and writing the result to 
    # the outfile
    def execute
      transpose = {}

      File.open(@infile).each_with_index do |line, index|
        line = unstring(line)
        next if line.empty?

        result = @col_filter.process(@row_filter.process(line, row: index))
        next if result.nil?

        result.split(';').each_with_index do |col, index|
          transpose[index] ||= []
          transpose[index] << col
        end
      end

      File.open(@outfile, 'w') do |out|
        transpose.values.each { |value| out.puts value.join(';') }
      end
    end

  end

end
