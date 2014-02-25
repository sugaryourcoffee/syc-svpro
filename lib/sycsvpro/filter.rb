require 'date'

# Operating csv files
module Sycsvpro

  # Creates a new filter that can be extended by sub-classes. A sub-class needs to override the
  # process method
  class Filter

    # When date are used as filters the date format has to be provided
    attr_reader :date_format
    # Filter for rows and columns
    attr_reader :filter
    # Type of column (n = number, s = string)
    attr_reader :types
    # Pattern that is used as a filter
    attr_reader :pattern
    # Comparison that is used as a filter
    attr_reader :pivot

    # Creates a new filter
    def initialize(values, options={})
      @date_format = options[:df] || "%Y-%m-%d"
      @filter  = []
      @types   = []
      @pattern = []
      @pivot   = {}
      create_filter(values)
    end

    # Creates the filters based on the given patterns
    def method_missing(id, *args, &block)
      return equal($1, args, block)              if id =~ /^(\d+)$/
      return equal_type($1, $2, args, block)     if id =~ /^(s|n|d):(\d+)$/
      return range($1, $2, args, block)          if id =~ /^(\d+)-(\d+)$/
      return range_type($1, $2, $3, args, block) if id =~ /^(s|n|d):(\d+)-(\d+)$/
      return regex($1, args, block)              if id =~ /^\/(.*)\/$/
      return col_regex($1, $2, args, block)      if id =~ /^(\d+):\/(.*)\/$/
      return date($1, $2, $3, args, block)       if id =~ /^(\d+):(<|=|>)(\d+.\d+.\d+)/
      return date_range($1, $2, $3, args, block) if id =~ /^(\d+):(\d+.\d+.\d+.)-(\d+.\d+.\d+)$/
      super
    end

    # Processes the filter. Needs to be overridden by the sub-class
    def process(object, options={})
      raise 'Needs to be overridden by sub class'
    end

    # Yields the column value and whether the filter matches the column
    def pivot_each_column(values=[])
      pivot.each do |column, parameters|
        value = values[parameters[:col].to_i]
        value = value.strip.gsub(/^"|"$/, "") unless value.nil?
        match = false
        begin
          match = eval(parameters[:operation].gsub('[value]', value))
        rescue
        end
        yield column, match
      end
    end

    # Checks whether a filter has been set. Returns true if filter has been set otherwise false
    def has_filter?
      return !(filter.empty? and pattern.empty?)
    end

    private

      # Creates a filter based on the provided rows and columns
      def create_filter(values)
        values.split(',').each { |f| send(f) } unless values.nil?
      end

      # Adds a single value to the filter
      def equal(value, args, block)
        filter << value.to_i unless filter.index(value.to_i) 
      end

      # Adds a single value and an associated type to the filter
      def equal_type(type, value, args, block)
        filter_size_before = filter.size
        equal(value, args, block)
        types << type if filter_size_before < filter.size
      end

      # Adds a range to the filter
      def range(start_value, end_value, args, block)
        filter << (start_value.to_i..end_value.to_i).to_a
      end

      # Adds a range and the associated types to the filter
      def range_type(type, start_value, end_value, args, block)
        filter_size_before = filter.size
        range(start_value, end_value, args, block)
        (filter.size - filter_size_before).times { types << type }
      end

      # Adds a regex to the pattern filter
      def regex(value, args, block)
        pattern << value unless pattern.index(value)
      end

      # Adds a comparisson filter 
      def col_regex(col, r, args, block)
        operation = "'[value]' =~ Regexp.new('#{r}')"
        pivot[r] = { col: col, operation: operation } 
      end

      # Adds a date filter
      def date(col, comparator, date, args, block)
        comparator = '==' if comparator == '='
        operation = "Date.strptime(\"[value]\", \"#{date_format}\") #{comparator} " +
                    "Date.strptime(\"#{date}\", \"#{date_format}\")"
        pivot["#{comparator}#{date}"] = { col: col, operation: operation }
      end

      # Adds a date range filter
      def date_range(col, start_date, end_date, args, block)
        operation = "   Date.strptime(\"#{start_date}\",  \"#{date_format}\") "    +
                    "<= Date.strptime(\"[value]\",        \"#{date_format}\") && " +
                    "   Date.strptime(\"[value]\",        \"#{date_format}\") "    +
                    "<= Date.strptime(\"#{end_date}\",    \"#{date_format}\")"
        pivot["#{start_date}-#{end_date}"] = { col: col, operation: operation }
      end

  end

end
