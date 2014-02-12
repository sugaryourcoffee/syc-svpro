require_relative 'filter'

module Sycsvpro

  class ColumnFilter < Filter
    
    def process(object, options={})
      return nil if object.nil?
      object = object.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      return object if filter.empty? and pivot.empty?
      filtered = object.split(';').values_at(*filter.flatten.uniq)
      pivot_each_column(object.split(';')) do |column, match|
        filtered << column if match
      end
      filtered.compact.join(';')
    end
    
  end

end
