require_relative 'row_filter'

module Dsl

  def rows(options={})
    infile     = File.expand_path(options[:infile])
    row_filter = Sycsvpro::RowFilter.new(options[:row_filter]) if options[:row_filter]

    puts "row filter = #{row_filter}"
    File.new(infile).each_with_index do |line, index|
      next if line.chomp.empty? 
      next if !row_filter.nil? and row_filter.process(line.chomp, row: index).nil?

      values = line.chomp.split(';') 
      params = []
      options.each { |k,v| params << extract_values(values, k, v) if k =~ /column$|columns$/ }

      yield *params
    end
  end

  def write_to(file)
    File.open(file, 'w') do |out|
      yield out
    end
  end

  private

    def extract_values(values, key, position)
      return values[position]            if key =~ /column$/
      return values.values_at(*position) if key =~ /columns$/
    end
end
