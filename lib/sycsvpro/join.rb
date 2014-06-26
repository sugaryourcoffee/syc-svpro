module Sycsvpro

  class Join

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # source file from where columns are inserted into infile
    attr_reader :source
    # filter that is used for rows
    attr_reader :row_filter
    # columns to insert
    attr_reader :columns
    # posititon where to insert the columns into the infile
    attr_reader :positions
    # header of the outfile
    attr_reader :header
    # lookup table where the assigned values are stored at
    attr_reader :lookup_table

    def initialize(options = {})
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @source     = options[:source]
      @row_filter = RowFilter.new(options[:rows], df: options[:df])
      @columns    = options[:cols].split(',').collect { |c| c.to_i }
      @positions  = options[:insert_col_pos].split(',').collect { |p| p.to_i }
      @joins      = options[:joins].split('=').collect { |j| j.to_i }
      @header     = Header.new(options[:header], 
                               pos:    @positions, 
                               insert: options[:insert_header])
      create_lookup_table
    end

    def execute
      processed_header = false

      File.open(outfile, 'w') do |out|
        File.open(infile).each_with_index do |line, index|
          line = line.chomp

          next if line.empty?

          line = unstring(line).chomp

          unless processed_header
            header_line = header.process(line)
            out.puts header unless header_line.empty?
            processed_header = true
            next
          end

          next if row_filter.process(line, row: index).nil?

          values = line.split(';')

          key = values[@joins[1]]
          row = lookup_table[:rows][key] || []

          lookup_table[:pos].sort.each { |p| values.insert(p, "") }
          lookup_table[:pos].each_with_index { |p,i| values[p] = row[i] } 

          out.puts values.join(';')
        end
      end
    end

    private

      def create_lookup_table
        @lookup_table = { pos: positions, rows: {} }

        File.open(source).each_with_index do |line|
          next if line.chomp.empty?

          values = unstring(line).chomp.split(';')

          next if values.empty?

          key = values[@joins[0]]
          lookup_table[:rows][key] = []

          columns.each do |i|
            lookup_table[:rows][key] << values[i]
          end
        end
      end
  end

end
