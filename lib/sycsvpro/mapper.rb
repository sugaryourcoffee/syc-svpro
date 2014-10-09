# Operating csv files
module Sycsvpro

  # Map values to new values described in a mapping file
  #
  # in.csv
  #
  #     | ID  | Name |
  #     | --- | ---- |
  #     | 1   | Hank |
  #     | 2   | Jane |
  #
  # mapping
  #
  #     1:01
  #     2:02
  #
  #     Sycsvpro::Mapping.new(infile:  "in.csv",
  #                           outfile: "out.csv",
  #                           mapping: "mapping",
  #                           cols:    "0").execute
  # out.csv
  #
  #     | ID  | Name |
  #     | --- | ---- |
  #     | 01  | Hank |
  #     | 02  | Jane |
  class Mapper

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # file that contains the mappings from existing column values to new values
    attr_reader :mapper
    # filter that is used for rows
    attr_reader :row_filter
    # filter that contains columns that are considered for mappings
    attr_reader :col_filter

    # Creates new mapper
    # :call-seq:
    #   Sycsvpro::Mapper.new(infile: "in.csv",
    #                        outfile: "out.csv",
    #                        mapping: "mapping.csv",
    #                        rows:    "1,3-5",
    #                        cols:    "3,4-7"
    #                        df:      "%Y-%m-%d").execute
    #
    # infile:: File that contains columns to be mapped
    # outfile:: File that contains the mapping result after execute
    # mapping:: File that contains the mappings. Mappings are separated by ':'
    # rows:: Rows to consider for mappings
    # cols:: Columns that should be mapped
    # df:: Date format for row filter if rows are filtered on date values
    def initialize(options={})
      @infile = options[:infile]
      @outfile = options[:outfile]
      @row_filter = RowFilter.new(options[:rows], df: options[:df])
      @col_filter = init_col_filter(options[:cols], @infile)
      @mapper = {}
      init_mapper(options[:mapping])
    end

    # Executes the mapper
    def execute
      File.open(outfile, 'w') do |out|
        File.new(infile, 'r').each_with_index do |line, index|
          result = row_filter.process(line, row: index)
          next if result.chomp.empty? or result.nil?
          result += ' ' if result =~ /;$/
          cols = result.split(';')
          @col_filter.each do |key|
            substitute = mapper[cols[key]]
            cols[key] = substitute if substitute
          end
          out.puts cols.join(';').strip
        end
      end
    end

    private

      # Initializes the mappings. A mapping consists of the value to be mapped
      # to another value. The values are spearated by colons ':'
      # Example:
      #     source_value:mapping_value
      def init_mapper(file)
        File.new(file, 'r').each_line do |line|
          from, to = unstring(line).split(':')
          mapper[from] = to
        end
      end

      # Initialize the col_filter that contains columns to be considered for
      # mapping. If no columns are provided, that is being empty, a filter with
      # all columns is returned 
      def init_col_filter(columns, source)
        if columns.nil?
          File.open(source, 'r').each do |line| 
            line = unstring(line)
            next if line.empty?
            line += ' ' if line =~ /;$/
            size = line.split(';').size
            columns = "0-#{size-1}"
            break
          end
        end
        ColumnFilter.new(columns).filter.flatten
      end

  end

end
