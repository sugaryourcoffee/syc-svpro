# Operating csv files
module Sycsvpro

  # Insert a text file into another textfile at a specified position
  class Inserter

    # file to insert lines to
    attr_reader :infile
    # file to write result to
    attr_reader :outfile
    # file that contains the lines to insert
    attr_reader :insert
    # position (top or bottom) where to insert the rows
    attr_reader :position

    # Creates an Inserter and takes options infile, outfile, insert-file and position where to
    # insert the insert-file content. Default position is top
    def initialize(options={})
      @infile  = options[:infile]
      @outfile = options[:outfile]
      @insert  = options[:insert]
      @position = options[:position] || 'top'
    end

    # Inserts the content of the insert-file at the specified positions (top or bottom)
    def execute
      File.open(outfile, 'w') do |out|
        if position.downcase == 'bottom'
          out.puts File.read(infile)
          out.puts File.read(insert)
        else
          out.puts File.read(insert)
          out.puts File.read(infile)
        end
      end
    end

  end

end
