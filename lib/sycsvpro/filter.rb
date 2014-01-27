module Sycsvpro

  class Filter

    attr_reader :filter, :pattern

    def initialize(values)
      @filter  = []
      @pattern = []
      create_filter(values)
    end

    def method_missing(id, *args, &block)
      return equal($1, args, block)    if id =~ /^(\d+)$/
      return range($1, $2, args, block) if id =~ /^(\d+)-(\d+)$/
      return regex($1, args, block)   if id =~ /^\/(.*)\/$/
      super
    end

    def process(object, options={})
      filtered = object.split(';').values_at(*filter.flatten.uniq)
      filtered.compact.join(';')
    end

    private

      def create_filter(values)
        values.split(',').each { |f| send(f) }
        puts filter.inspect
        puts pattern.inspect
      end

      def equal(value, args, block)
        puts "equal #{value}"
        filter << value.to_i unless filter.index(value.to_i) 
      end

      def range(start_value, end_value, args, block)
        filter << (start_value.to_i..end_value.to_i).to_a
      end

      def regex(value, args, block)
        puts "regex #{value}"
        pattern << value unless pattern.index(value)
      end

  end

end
