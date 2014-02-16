# Operating csv files
module Sycsvpro

  # Map values to new values described in a mapping file
  class Mapper

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # file that contains the mappings from existing column values to new values
    attr_reader :mapper
    # filter that is used for rows
    attr_reader :row_filter
    # filter that is used for columns
    attr_reader :col_filter

    # Creates new mapper
    def initialize(options={})
      @infile = options[:infile]
      @outfile = options[:outfile]
      @row_filter = RowFilter.new(options[:row_filter])
      @col_filter = ColumnFilter.new(options[:col_filter])
      @mapper = {}
      init_mapper(options[:mapping])
    end

    # Executes the mapper
    def execute
      File.open(outfile, 'w') do |out|
        File.new(infile, 'r').each_with_index do |line, index|
          result = col_filter.process(row_filter.process(line, row: index))
          next if result.chomp.empty? or result.nil?
          mapper.each do |from, to|
            result = result.chomp.gsub(/(?<=^|;)#{from}(?=;|$)/, to)
          end
          out.puts result
        end
      end
    end

    private

      # Initializes the mappings
      def init_mapper(file)
        File.new(file, 'r').each_line do |line|
          from, to = line.chomp.split(':')
          mapper[from] = to
        end
      end
  end

end
