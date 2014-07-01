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

    # header based on that the files get merged
    attr_reader :header
    # header columns
    attr_reader :header_cols
    # files to be merged based on header columns
    attr_reader :files
    # file to that the result is written to
    attr_reader :outfile

    # Merge files based on common header columns
    #
    # :call-seq:
    #   Sycsvpro::Merger.new(outfile: "out.csv",
    #                        files:   "file1.csv,file2.csv,filen.csv",
    #                        header:  "2010,2011,2012,2013,2014").execute
    # outfile:: result is written to the outfile
    # files:: list of files that get merged. In the result file the files are
    # inserted in the sequence they are provided
    # header:: header of the result file and key for assigning column values
    # from source files to result file
    def initialize(options = {})
      @outfile      = options[:outfile]
      @header       = options[:header].gsub(',', ';')
      @header_cols  = options[:header].split(',')
      @files        = options[:files].split(',')
    end

    def execute
      File.open(outfile, 'w') do |out|
        out.puts header
        files.each do |file|
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
        @file_header = []
        header_cols.each_with_index do |h,i|
          if h.empty? and i == 0
            @file_header << 0
          else
            @file_header << columns.index(h) 
          end
        end 
        @file_header.compact!
      end

      # create a line filtered by the file_header
      def create_line(columns)
        columns.values_at(*@file_header).join(';')
      end

  end

end
