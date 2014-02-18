require_relative 'row_filter'

# Methods to be used in customer specific script files
module Dsl

  # Retrieves rows and columns from the file and returns them to the block provided by the caller
  def rows(options={})
    infile     = File.expand_path(options[:infile])
    row_filter = Sycsvpro::RowFilter.new(options[:row_filter]) if options[:row_filter]

    File.new(infile).each_with_index do |line, index|
      next if line.chomp.empty? 
      next if !row_filter.nil? and row_filter.process(line.chomp, row: index).nil?

      values = line.chomp.split(';') 
      params = []
      options.each { |k,v| params << extract_values(values, k, v) if k =~ /column$|columns$/ }

      yield *params
    end
  end

  # writes values provided by a block to the given file
  def write_to(file)
    File.open(file, 'w') do |out|
      yield out
    end
  end

  # Remove leading and trailing " and spaces as well as reducing more than 2 spaces between words
  # from csv values like "a";ba   g;c;"d";e to a;b ag;c;d;e
  def unstring(line)
    line.gsub(/(?<=^|;)\s*"?\s*|\s*"?\s*(?=;|$)/, "").gsub(/\s{2,}/, " ") unless line.nil?
  end

  private

    # Assigns values to keys that are used in rows and yielded to the block
    def extract_values(values, key, position)
      return values[position]            if key =~ /column$/
      return values.values_at(*position) if key =~ /columns$/
    end
end
