require 'date'

module Sycsvpro

  class Filter

    attr_reader :date_format, :filter, :pattern, :pivot

    def initialize(values, options={})
      @date_format = options[:df] || "%Y-%m-%d"
      @filter  = []
      @pattern = []
      @pivot   = {}
      create_filter(values)
    end

    def method_missing(id, *args, &block)
      return equal($1, args, block)              if id =~ /^(\d+)$/
      return range($1, $2, args, block)          if id =~ /^(\d+)-(\d+)$/
      return regex($1, args, block)              if id =~ /^\/(.*)\/$/
      return col_regex($1, $2, args, block)      if id =~ /^(\d+):\/(.*)\/$/
      return date($1, $2, $3, args, block)       if id =~ /^(\d+):(<|=|>)(\d+.\d+.\d+)/
      return date_range($1, $2, $3, args, block) if id =~ /^(\d+):(\d+.\d+.\d+.)-(\d+.\d+.\d+)$/
      super
    end

    def process(object, options={})
      raise 'Needs to be overridden by sub class'
    end

    def pivot_each_column(values=[])
      pivot.each do |column, parameters|
        yield column, eval(parameters[:operation].gsub('[value]', values[parameters[:col].to_i]))
      end
    end

    private

      def create_filter(values)
        values.split(',').each { |f| send(f) } unless values.nil?
      end

      def equal(value, args, block)
        filter << value.to_i unless filter.index(value.to_i) 
      end

      def range(start_value, end_value, args, block)
        filter << (start_value.to_i..end_value.to_i).to_a
      end

      def regex(value, args, block)
        pattern << value unless pattern.index(value)
      end

      def col_regex(col, r, args, block)
        operation = "'[value]' =~ Regexp.new('#{r}')"
        pivot[r] = { col: col, operation: operation } 
      end

      def date(col, comparator, date, args, block)
        operation = "Date.strptime(\"[value]\", \"#{date_format}\") #{comparator} " +
                    "Date.strptime(\"#{date}\", \"#{date_format}\")"
        pivot["#{comparator}#{date}"] = { col: col, operation: operation }
      end

      def date_range(col, start_date, end_date, args, block)
        operation = "   Date.strptime(\"#{start_date}\",  \"#{date_format}\") "    +
                    "<= Date.strptime(\"[value]\",        \"#{date_format}\") && " +
                    "   Date.strptime(\"[value]\",        \"#{date_format}\") "    +
                    "<= Date.strptime(\"#{end_date}\",    \"#{date_format}\")"
        pivot["#{start_date}-#{end_date}"] = { col: col, operation: operation }
      end

  end

end
