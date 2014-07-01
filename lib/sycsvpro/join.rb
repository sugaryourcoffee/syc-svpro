# Operating csv files
module Sycsvpro

  # Joiner holds all join data as join columns, positions where to insert the
  # columns from the source file, cols wich are the cols inserted from the
  # source file and the lookup table with keys and associated column values.
  # :call-seq:
  #   Sycsvpro::Joiner.new([1,2], [3,4], [4,5,6], { rows: {} }
  Joiner = Struct.new(:join, :pos, :cols, :lookup)

  # Join joins two files based on a join key value.
  # Example
  # File 1 (infile)
  #     |Name |ID |
  #     |-----|---|
  #     |Hank |123|
  #     |Frank|234|
  #     |Mia  |345|
  #     |Moira|234|
  #
  # File 2 (source)
  #     |Company|Phone|ID |
  #     |-------|-----|---|
  #     |Siem   |4848 |123|
  #     |Helo   |993  |345|
  #     |Wara   |3333 |234|
  #
  # File 3 (outfile)
  #     |Name |ID |Company|Phone|
  #     |-----|---|-------|-----|
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
    # posititon where to insert the columns into the infile
    attr_reader :positions
    # header of the outfile
    attr_reader :header
    # indicates whether the infile is headerless
    attr_reader :headerless

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
    # rows:: rows to consider for operation. Rows that don't match the pattern
    #        will be skipped for operation
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
      @positions  = create_joiners(options[:joins], 
                                   options[:cols], 
                                   options[:pos])
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
          target = values.dup

          @positions.sort.each { |p| target.insert(p, "") }
          
          @joiners.each do |joiner|
            key = values[joiner.join[1]]
            row = joiner.lookup[:rows][key] || []
            joiner.pos.each_with_index { |p,i| target[p] = row[i] }
          end

          out.puts target.join(';')
        end
      end
    end

    private

      # Creates a lookup table from the source file values. The join column of
      # the source file is the key
      def create_lookup_table
        File.open(source).each_with_index do |line|
          next if line.chomp.empty?

          values = unstring(line).chomp.split(';')

          next if values.empty?

          @joiners.each do |joiner|
            key = values[joiner.join[0]]
            joiner.lookup[:rows][key] = []

            joiner.cols.each do |i|
              joiner.lookup[:rows][key] << values[i]
            end
          end

        end
      end
     
      # Initializes the column positions where the source file columns have to
      # be inserted. If no column positions are provided the inserted columns
      # are put at the beginning of the row
      def col_positions(pos, cols)
        if pos.nil? || pos.empty?
          pos = []
          cols.each { |c| pos << Array.new(c.size) { |c| c } }
          pos
        else
          pos.split(';').collect { |p| p.split(',').collect { |p| p.to_i } }
        end
      end

      # Initializes joiners based on joins, positions and columns
      #
      # Possible input forms are:
      # joins:: "4=0;4=1" or "4=1"
      # positions:: "1,2;4,5" or "1,2"
      # columns:: "1,2;3,4" 
      #
      # This has the semantic of 'insert columns 1 and 2 at positions 1 and 2
      # for key 0 and columns 3 and 4 at positions 4 and 5 for key 1. Key 4 is
      # the corresponding value in the source file
      #
      # Return value:: positions where to insert values from source file
      def create_joiners(j, c, p)
        js = j.split(';').collect { |j| j.split('=').collect { |j| j.to_i } }
        cs = c.split(';').collect { |c| c.split(',').collect { |c| c.to_i } }
        ps = col_positions(p, cs)

        @joiners = []
        (0...js.size).each do |i| 
          @joiners << Joiner.new(js[i], ps[i], cs[i], { rows: { } }) 
        end 

        ps.flatten
      end

  end

end
