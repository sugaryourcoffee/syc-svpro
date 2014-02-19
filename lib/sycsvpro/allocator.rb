# Operating csv files
module Sycsvpro

  # Allocates columns to a key column
  class Allocator

    # File from that values are read
    attr_reader :infile
    # File to that result of allocation is written
    attr_reader :outfile
    # Filter for rows to consider
    attr_reader :row_filter
    # Filter for columns to allocate
    attr_reader :col_filter
    # Filter for the key column that the values are allocated at
    attr_reader :key_filter

    # Creates a new allocator. Options are infile, outfile, key, rows and columns to allocate to key
    def initialize(options={})
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @key_filter = ColumnFilter.new(options[:key])
      @row_filter = RowFilter.new(options[:rows])
      @col_filter = ColumnFilter.new(options[:cols])
    end

    # Executes the allocator and assigns column values to the key
    def execute
      allocation = {}
      File.open(infile).each_with_index do |line, index|
        row = row_filter.process(line, row: index)
        next if row.nil?
        key = key_filter.process(row)
        allocation[key] = [] if allocation[key].nil?
        allocation[key] << col_filter.process(row).split(';') 
      end

      File.open(outfile, 'w') do |out|
        allocation.each do |key, values|
          out.puts "#{key};#{values.flatten.uniq.sort.join(';')}"
        end
      end
    end

  end

end
