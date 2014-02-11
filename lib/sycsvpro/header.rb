require_relative 'filter'

module Sycsvpro

  class Header < Filter

    attr_reader :header_cols

    def initialize(header)
      unless header.nil? or header.empty?
        @header_cols = header.split(',')
      else
        @header_cols = []
      end
    end

    def process(line)
      return "" if @header_cols.empty?
      @header_cols[0] = line.split(';')
      @header_cols.flatten.join(';')
    end
  end

end
