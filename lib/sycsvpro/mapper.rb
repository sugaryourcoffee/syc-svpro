module Sycsvpro

  class Mapper

    attr_reader :infile, :outfile, :mapper, :row_filter, :col_filter

    def initialize(options={})
      @infile = options[:infile]
      @outfile = options[:outfile]
      @row_filter = RowFilter.new(options[:row_filter])
      @col_filter = ColumnFilter.new(options[:col_filter])
      @mapper = {}
      init_mapper(options[:mapping])
    end

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

      def init_mapper(file)
        File.new(file, 'r').each_line do |line|
          from, to = line.chomp.split(':')
          mapper[from] = to
        end
      end
  end

end
