require_relative 'filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # Creates a header
  class Header < Filter

    include Dsl

    # Header columns
    attr_reader :header_cols
    # Columns that will be inserted into the header at the defined positions
    attr_reader :insert_cols
    # Positions where to insert the insert_cols
    attr_reader :positions

    # Create a new header
    def initialize(header, options = {})
      @header_cols = split_by_comma_regex(header || "")
      @insert_cols = (options[:insert] || "").split(',')
      @positions   = options[:pos] || []
    end

    def method_missing(id, *args, &block)
      return @row_cols[$1.to_i] if id =~ /^c(\d+)$/
      super
    end

    # Returns the header
    def process(line, values = true)
      return "" if @header_cols.empty? && @insert_cols.empty?
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
                if values
                  @header_cols[i] = (h =~ /^c\d+=~/) ? last_eval : col
                  header_patterns[i+1] = h if h =~ /^c\d+[=~+-]{1,2}/
                else
                  @header_cols[i] = col if h =~ /^c\d+$/
                end
              end
            end
          else
            @header_cols[i] = h
          end
        end
      end
      insert_header_cols
      header_patterns.each { |i,h| @header_cols.insert(i,h) }
      to_s
    end

    # Returns @header_cols without pattern
    def clear_header_cols
      @header_cols.select { |col| col !~ /^c\d+[=~+]{1,2}/ }
    end

    # Returns the index of the column
    def column_of(value)
      clear_header_cols.index(value)
    end

    # Returns the value of column number
    def value_of(column)
      clear_header_cols[column]
    end

    # Returns the header
    def to_s
      clear_header_cols.join(';')
    end

    private

      def insert_header_cols
        @header_cols.flatten!
        positions.sort.each { |p| header_cols.insert(p, "") }
        positions.each_with_index { |p,i| header_cols[p] = insert_cols[i] }
      end

  end

end
