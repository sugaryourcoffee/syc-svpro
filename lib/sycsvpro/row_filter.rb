require_relative 'filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # Filters rows based on provided patterns
  class RowFilter < Filter
    
    include Dsl

    # Processes the filter on the given row
    def process(object, options={})
      object = unstring(object)
      return object unless has_filter?
      filtered = !filter.flatten.uniq.index(options[:row]).nil?
      pattern.each do |p|
        filtered = (filtered or !(object =~ Regexp.new(p)).nil?)
      end
      filtered = (filtered or match_boolean_filter?(object.split(';')))
      filtered ? object : nil
    end
    
  end
  
end
