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

    def initialize(options={})
      @infile  = options[:infile]
      @outfile = options[:outfile]
      @insert  = options[:insert]
    end

    def execute
      File.open(outfile, 'w') do |out|
        out.puts File.read(insert)
        out.puts File.read(infile)
      end
    end

  end

end
