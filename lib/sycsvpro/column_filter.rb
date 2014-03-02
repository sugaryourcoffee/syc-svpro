require_relative 'filter'

# Operating csv files
module Sycsvpro

  # Creates a new column filter
  class ColumnFilter < Filter
    
    # Processes the filter and returns the values that respect the filter
    def process(object, options={})
      return nil if object.nil? or object.empty?
      object = object.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      object += " " if object =~ /;$/
      return object if filter.empty? and pivot.empty?
      filtered = object.split(';').values_at(*filter.flatten.uniq)
      pivot_each_column(object.split(';')) do |column, match|
        filtered << column if match
      end
      if !filtered.last.nil? and filtered.last.empty?
        filtered.compact.join(';') + " " 
      else
        filtered.compact.join(';')
      end
    end
    
  end

end
