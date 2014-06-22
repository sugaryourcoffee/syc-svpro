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

    def method_missing(id, *args, &block)
      return @row_cols[$1.to_i] if id =~ /^c(\d+)$/
      super
    end

    # Returns the header
    def process(line)
      return "" if @header_cols.empty?
      header_patterns = {}
      @row_cols = unstring(line).split(';')
      if @header_cols[0] == '*'
        @header_cols[0] = @row_cols
      else
        @header_cols.each_with_index do |h,i|
          if h =~ /^c\d+(?:[=~]{,2}).*$/ 
            if col = eval(h)
              last_eval = $1
              unless @header_cols.index(last_eval) || @header_cols.index(col)
                @header_cols[i] = (h =~ /^c\d+=~/) ? last_eval : col
                header_patterns[i+1] = h if h =~ /^c\d+[=~+-]{1,2}/
              end
            end
          else
            @header_cols[i] = h
          end
        end
      end
      header_patterns.each { |i,h| @header_cols.insert(i,h) }
      to_s
    end

    # Returns the index of the column
    def column_of(value)
      @header_cols.flatten.select { |col| col !~ /^c\d+[=~+]{1,2}/ }.index(value)
    end

    # Returns the header
    def to_s
      @header_cols.flatten.select { |col| col !~ /^c\d+[=~+]{1,2}/ }.join(';')
    end

  end

end
