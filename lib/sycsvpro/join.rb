# Operating csv files
module Sycsvpro

  # Join joins two files based on a join key value.
  # Example
  # File 1 (infile)
  #     |Name |ID |
  #     |Hank |123|
  #     |Frank|234|
  #     |Mia  |345|
  #     |Moira|234|
  #
  # File 2 (source)
  #     |Company|Phone|ID|
  #     |Siem   |4848 |123|
  #     |Helo   |993  |345|
  #     |Wara   |3333 |234|
  #
  # File 3 (outfile)
  #     |Name |ID |Company|Phone|
  #     |Hank |123|Siem   |4848 |
  #     |Frank|234|Wara   |3333 |
  #     |Mia  |345|Helo   |993  |
  #     |Moira|234|Wara   |3333 | 
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
    # indicates whether the infile is headerless
    attr_reader :headerless
    # lookup table where the assigned values are stored at
    attr_reader :lookup_table

    # Creates a Join which can be invoked as follows
    # :call-seq:
    #   Sycsvpro::Join.new(infile:  "in.csv",
    #                      outfile: "out.csv",
    #                      source:  "source.csv",
    #                      rows:    "1-eof",
    #                      cols:    "0,1",
    #                      pos:     "2,3",
    #                      joins:   "2=1",
    #                      headerless: true,
    #                      header:  "*",
    #                      insert_header: "Company,Phone").execute
    #
    # infile:: csv file to operate on
    # outfile:: csv file with the result
    # source:: csv file that contains the values to join to infile
    # rows: rows to consider for operation. Rows that don't match the pattern
    #       will be skipped for operation
    # cols:: columns to insert from the source to the infile
    # pos:: column positions where to insert the values and the insert_header
    #       columns
    # joins:: columns that match in infile and source.
    #         source_column=infile_column
    # headerless:: indicates whether the infile has a header (default true)
    # header:: Header of the csv file
    # insert_header:: column names of the to be inserted values
    def initialize(options = {})
      @infile     = options[:infile]
      @outfile    = options[:outfile]
      @source     = options[:source]
      @row_filter = RowFilter.new(options[:rows], df: options[:df])
      @columns    = options[:cols].split(',').collect { |c| c.to_i }
      @positions  = col_positions(options[:pos], @columns)
      @joins      = options[:joins].split('=').collect { |j| j.to_i }
      @headerless = options[:headerless].nil? ? false : options[:headerless]
      @header     = Header.new(options[:header] || '*', 
                               pos:    @positions, 
                               insert: options[:insert_header])
      create_lookup_table
    end

    # Executes the join
    def execute
      processed_header = headerless ? true : false

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

      # Creates a lookup table from the source file values. The join column of
      # the source file is the key
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

      # Initializes the column positions where the source file columns have to
      # be inserted. If no column positions are provided the inserted columns
      # are put at the beginning of the row
      def col_positions(pos, cols)
        if pos.nil? || pos.empty?
          Array.new(cols.size) { |c| c }
        else
          pos.split(',').collect { |p| p.to_i }
        end
      end

  end

end
