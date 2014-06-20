require_relative 'row_filter'
require_relative 'column_type_filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # Sorts an input file based on a column sort filter
  class Sorter

    include Dsl

    # file of the data to sort
    attr_reader :infile
    # file to write the sorted data to
    attr_reader :outfile
    # row filter
    attr_reader :row_filter
    # column type filter
    attr_reader :col_type_filter
    # sorted rows
    attr_reader :sorted_rows
    # file doesn't contain a header. If not headerless then empty rows from
    # beginning of file are discarted and first non empty row is considered as
    # header. Subsequent rows will be sorted and added in the resulting file
    # after the header
    attr_reader :headerless
    # First row to sort. Will skip rows 0 to start - 1 and add them to top of
    # file. Rows from start on will be sorted.
    attr_reader :start
    # sort order descending or ascending
    attr_reader :desc

    # Creates a Sorter and takes as options infile, outfile, rows, cols 
    # including types and a date format for the date columns to sort (optional).
    # :call-seq:
    #   Sycsvrpo::Sorter.new(infile:     "infile.csv",
    #                        outfile:    "outfile.csv",
    #                        rows:       "1,2-5,12-30",
    #                        cols:       "n:1,s:3",
    #                        headerless: true,
    #                        df:         "%d.%m.%Y",
    #                        start:      "2").execute
    # The sorted infile will saved to outfile
    def initialize(options={})
      @infile          = options[:infile]
      @outfile         = options[:outfile]
      @headerless      = options[:headerless] || false
      @start           = options[:start]
      @desc            = options[:desc] || false
      @row_filter      = RowFilter.new(options[:rows], df: options[:df])
      @col_type_filter = ColumnTypeFilter.new(options[:cols], df: options[:df])
      @sorted_rows     = []
    end

    # Sorts the data of the infile
    def execute
      rows = File.readlines(infile)

      skipped_rows = []

      unless headerless
        skipped_rows[0] = ""
        skipped_rows[0] = rows.shift while skipped_rows[0].chomp.strip.empty?
      end

      if start
        (0...start.to_i).each { |row| skipped_rows << rows.shift }  
      end

      rows.each_with_index do |line, index|
        filtered = col_type_filter.process(row_filter.process(line, row: index))
        next if filtered.nil?
        sorted_rows << (filtered << index)
      end

      File.open(outfile, 'w') do |out|
        skipped_rows.each { |row| out.puts unstring(row) }

        if desc
          sorted_rows.compact.sort.reverse.each do |row|
            out.puts unstring(rows[row.last])
          end
        else
          sorted_rows.compact.sort.each do |row|
            out.puts unstring(rows[row.last])
          end
        end
      end
    end

  end

end
