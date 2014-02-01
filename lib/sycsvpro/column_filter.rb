require_relative 'filter'

module Sycsvpro

  class ColumnFilter < Filter
    
    def process(object, options={})
      return nil if object.nil?
      return object if filter.empty?
      filtered = object.split(';').values_at(*filter.flatten.uniq)
      filtered.compact.join(';')
    end
    
  end

end
