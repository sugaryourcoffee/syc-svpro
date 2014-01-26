module Sycsvpro

  class Filter

    attr_reader :filter

    def initialize(filter)
      @filter = filter
    end

    def method_missing(id, *args, &block)
      return "greater(#{$1}, #{args}, block)" if id =~ /^>(\d+)$/
      return "less(#{$1}, #{args}, block)"   if id =~ /^<(\d+)$/
      return "equal(#{$1}, #{args}, block)"  if id =~ /^(\d+)$/
      return "range(#{$1}, #{$2}, #{args}, block)"  if id =~ /^(\d+)-(\d+)$/
      return "pattern(#{$1}, #{args}, block)"      if id =~ /^\/(.*)\/$/
      super
    end

    def max?
      return 10
    end

    def process(object, options={})
      values = object.split(';')
      filtered = []
      filter.split(',').each do |f|
        filtered << send(f, values)
      end  
      filtered
    end

  end

end
