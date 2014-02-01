require_relative 'filter'

module Sycsvpro

  class RowFilter < Filter
    
    def process(object, options={})
      filtered = (!filter.flatten.uniq.index(options[:row]).nil? or filter.empty?)
      puts "row filtered = #{filtered} filter empty = #{filter.empty?}"
      pattern.each do |p|
        filtered = (filtered or !(object =~ Regexp.new(p)).nil?)
      end
      filtered ? object : nil
    end
    
  end

end
