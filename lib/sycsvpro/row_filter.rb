require_relative 'filter'

# Operating csv files
module Sycsvpro

  # Filters rows based on provided patterns
  class RowFilter < Filter
    
    # Processes the filter on the given row
    def process(object, options={})
      filtered = (!filter.flatten.uniq.index(options[:row]).nil? or filter.empty?)
      pattern.each do |p|
        filtered = (filtered or !(object =~ Regexp.new(p)).nil?)
      end
      filtered ? object : nil
    end
    
  end

end
