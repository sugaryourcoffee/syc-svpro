require 'set'

# Operating csv files
module Sycsvpro

  # Removes copies of rows identified by key values
  #
  #     | Name | Street | Town | Country |
  #     | ---- | ------ | ---- | ------- |
  #     | Jane | Canal  | Win  | CA      |
  #     | Jack | Long   | Van  | CA      |
  #     | Jean | Sing   | Ma   | DE      |
  #     | Jane | Canal  | Win  | CA      |
  #
  # Remove copies based on column 0 (Name)
  #
  #     | Name | Street | Town | Country |
  #     | ---- | ------ | ---- | ------- |
  #     | Jane | Canal  | Win  | CA      |
  #     | Jack | Long   | Van  | CA      |
  #     | Jean | Sing   | Ma   | DE      |
  class Unique

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # filter that is used for rows
    attr_reader :row_filter
    # filter that is used for columns
    attr_reader :col_filter

    # Creates a new Unique
    #   Sycsvpro::Unique.new(infile: "infile.csv",
    #                        outfile: "outfile.csv",
    #                        rows:    "1,3-4",
    #                        cols:    "0,2,4-6",
    #                        key:     "0,1").execute
    def initialize(options = {})
      @infile  = options[:infile]
      @outfile = options[:outfile]
      @row_filter = RowFilter.new(options[:rows], df: options[:df])
      @col_filter = ColumnFilter.new(options[:cols], df: options[:df])
      @key_filter = ColumnFilter.new(options[:key], df: options[:df])
      @keys = Set.new
    end

    # Removes the duplicates from infile and writes the result to outfile
    def execute
      File.open(@outfile, 'w') do |out|
        File.open(@infile, 'r').each_with_index do |line, index|
          line = line.chomp

          next if line.empty?
          
          line = unstring(line).chomp

          extraction = col_filter.process(row_filter.process(line, row: index))

          next unless extraction

          key = @key_filter.process(line)
          
          unless @keys.include? key
            out.puts extraction
            @keys << key
          end
        end
      end
    end

  end

end
