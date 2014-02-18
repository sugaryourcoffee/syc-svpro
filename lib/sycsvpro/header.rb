require_relative 'filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # Creates a header
  class Header < Filter

    include Dsl

    # Header columns
    attr_reader :header_cols

    # Create a new header
    def initialize(header)
      unless header.nil? or header.empty?
        @header_cols = header.split(',')
      else
        @header_cols = []
      end
    end

    # Returns the header
    def process(line)
      return "" if @header_cols.empty?
      @header_cols[0] = unstring(line).split(';')
      @header_cols.flatten.join(';')
    end
  end

end
