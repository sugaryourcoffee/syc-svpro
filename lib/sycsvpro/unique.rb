require 'set'

module Sycsvpro

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

    def initialize(options = {})
      @infile  = options[:infile]
      @outfile = options[:outfile]
      @row_filter = RowFilter.new(options[:rows], df: options[:df])
      @col_filter = ColumnFilter.new(options[:cols], df: options[:df])
      @key_filter = ColumnFilter.new(options[:key], df: options[:df])
      @headerless = options[:headerless]
      @keys = Set.new
    end

    def execute
      processed_header = !@headerless

      File.open(@outfile, 'w') do |out|
        File.open(@infile, 'r').each_with_index do |line, index|
          line = line.chomp

          next if line.empty?
          
          line = unstring(line).chomp

          unless processed_header
            out.puts col_filter.process(line)
            process_header = true
          end

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
