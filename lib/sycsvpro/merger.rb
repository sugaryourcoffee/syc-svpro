# Operating csv files
module Sycsvpro

  # Merge files based on common header columns
  #
  # file1.csv
  #
  # |     | 2010 | 2011 | 2012 | 2013 |
  # | --- | ---- | ---- | ---- | ---- |
  # | SP  | 20   | 30   | 40   | 50   |
  # | RP  | 30   | 40   | 50   | 60   |
  #
  # file2.csv
  #
  # |     | 2010 | 2011 | 2012 |
  # | --- | ---- | ---- | ---- |
  # | M   | m1   | m2   | m3   |
  # | N   | n1   | n2   | n3   |
  #
  # merging restults in
  #
  # merge.csv
  #
  # |     | 2010 | 2011 | 2012 | 2013 |
  # | --- | ---- | ---- | ---- | ---- |
  # | SP  | 20   | 30   | 40   | 50   |
  # | RP  | 30   | 40   | 50   | 60   |
  # | M   | m1   | m2   | m3   |      |
  # | N   | n1   | n2   | n3   |      |
  #
  class Merger

    include Dsl

    # file to that the result is written
    attr_reader :outfile
    # header patterns to be used to identify merge columns
    attr_reader :source_header
    # header columns
    attr_reader :header_cols
    # value that is used as first of column of a row
    attr_reader :key
    # files to be merged based on header columns
    attr_reader :files
    # file to that the result is written to
    attr_reader :outfile

    # Merge files based on common header columns
    #
    # :call-seq:
    #   Sycsvpro::Merger.new(outfile:       "out.csv",
    #                        files:         "file1.csv,file2.csv,filen.csv",
    #                        header:        "2010,2011,2012,2013,2014",
    #                        source_header: "(\\d{4}/),(/\\d{4}/)",
    #                        key:           "0,0").execute
    #
    # Semantics
    # =========
    # Merges the files file1.csv, file2.csv ... based on the header columns
    # 2010, 2011, 2012, 2013 and 2014 where columns are identified by the 
    # regex /(\d{4})/. The first column in a row is column 0 of the file1.csv
    # and so on.
    #
    # outfile:: result is written to the outfile
    # files:: list of files that get merged. In the result file the files are
    # inserted in the sequence they are provided
    # header:: header of the result file and key for assigning column values
    # from source files to result file
    # source_header:: pattern for each header of the source file to determine
    # the column. The pattern is a regex without the enclosing slashes '/'
    # key:: first column value from the source file that is used as first
    # column in the target file
    def initialize(options = {})
      @outfile       = options[:outfile]
      @header_cols   = options[:header].split(',')
      @source_header = options[:source_header].split(',')
      @key           = options[:key].split(',')
      @files         = options[:files].split(',')
    end

    # Merges the files based on the provided parameters
    def execute
      File.open(outfile, 'w') do |out|
        out.puts ";#{header_cols.join(';')}"
        files.each do |file|
          @current_key = @key.shift
          @current_source_header = @source_header.shift
          processed_header = false
          File.open(file).each_with_index do |line, index|
            next if line.chomp.empty?

            unless processed_header
              create_file_header unstring(line).split(';')
              processed_header = true
              next
            end

            out.puts create_line unstring(line).split(';')
          end
        end
      end
    end

    private

      # create a filter for the columns that match the header filter
      def create_file_header(columns)
        columns.each_with_index do |c,i|
          next if i == @current_key
          columns[i] = c.scan(Regexp.new(@current_source_header)).flatten[0]
        end

        @file_header = [@current_key.to_i]
        header_cols.each do |h|
          @file_header << columns.index(h) 
        end 
        @file_header.compact!
      end

      # create a line filtered by the file_header
      def create_line(columns)
        columns.values_at(*@file_header).join(';')
      end

  end

end
