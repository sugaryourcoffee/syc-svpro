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
  # from csv values. Replac ; with , from values as ; is used as value separator
  def unstring(line)
    line = str2utf8(line)
    line.scan(/(?<=^"|;")[^"]+(?=;)+[^"]*|;+[^"](?=";|"$)/).each do |value|
      line = line.gsub(value, value.gsub(';', ','))
    end
    line.gsub(/(?<=^|;)\s*"?\s*|\s*"?\s*(?=;|$)/, "").gsub(/\s{2,}/, " ") unless line.nil?
  end

  # Remove non-UTF chars from string
  def str2utf8(str)
    str.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  end

  private

    # Assigns values to keys that are used in rows and yielded to the block
    def extract_values(values, key, position)
      return values[position]            if key =~ /column$/
      return values.values_at(*position) if key =~ /columns$/
    end
end
