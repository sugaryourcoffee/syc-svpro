require_relative 'filter'

module Sycsvpro

  class RowFilter < Filter
    
    def process(object, options={})
      filtered = !filter.flatten.uniq.index(options[:row]).nil?
      pattern.each do |p|
        filtered = (filtered or !(object =~ Regexp.new(p)).nil?)
      end
      filtered ? object : nil
    end
    
  end

end
