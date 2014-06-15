require_relative 'filter'
require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # Filters rows based on provided patterns
  class RowFilter < Filter
    
    include Dsl

    # Processes the filter on the given row
    def process(object, options={})
      STDERR.puts "object = #{object}"
      object = unstring(object)
      return object unless has_filter?
      filtered = !filter.flatten.uniq.index(options[:row]).nil?
      pattern.each do |p|
        STDERR.puts "pattern = #{pattern}"
        filtered = (filtered or !(object =~ Regexp.new(p)).nil?)
      end
      filtered ? object : nil
    end
    
  end
  
  # Match a logical row filter
  # Example: 1,2,3,4-5:c1=10&&c2<20||c3>4&&c4=word||c5=2014-3-2&&c6=/\d{3,4}/  
  # (\d+(?:,\d+|-\d)*):(c\d+[<=>](?:\d{4}-\d{1,2}-\d{1,2}|\d+|\w+|\/.*?\/)(?:(?:&&|\|\||$)c\d+[<=>](?:\d{4}-\d{1,2}-\d{1,2}|\d+|\w+|\/.*?\/))*)
  # This will match
  # 1. 1,2,3,4-5
  # 2. c1=10&&c2<20||c3>4&&c4=word||c5=2014-3-2&&c6=/\d{3,4}/  
end
