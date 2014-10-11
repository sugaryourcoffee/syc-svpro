require_relative 'row_filter'

# Methods to be used in customer specific script files
module Dsl
  
  # Splits comma separated strings that contain commas within the value. Such
  # values have to be enclosed between BEGIN and END
  # Example:
  #     Year,c1+c2,c1=~/[A-Z]{1,2}/,Month
  COMMA_SPLITTER_REGEX = /(?<=,|^)(BEGIN.*?END|\/.*?\/|.*?)(?=,|$)/i
  # Recognizes a string that represents an integer value
  INTEGER_REGEX = /^\d{1,3}(?:[,\. ]\d{3}|\d)*$/
  COMMA_POINT_SPACE_REGEX = /[,\. ]/
  # Recognizes a string that represents a float value in the form of 1,333.45
  DECIMAL_POINT_REGEX = /^\d{1,3}(?:[, ]\d{3}|\d)*(?:\.\d*)$/
  # Recognizes a string that represents a float value in the form of 1.333,45
  DECIMAL_COMMA_REGEX = /^\d{1,3}(?:[\. ]\d{3}|\d)*(?:,\d*)$/
  # A regex that recognizes '.' and ' ' to be used e.g. in #gsub to optimize performance
  POINT_SPACE_REGEX    = /[\. ]/
  # A regex that recognizes ',' and ' ' to be used e.g. in #gsub to optimize performance
  COMMA_SPACE_REGEX    = /[, ]/
  # A point '.' to be used e.g. in #gsub to optimize performance
  POINT = '.'
  # A comma ',' to be used e.g. in #gsub to optimize performance
  COMMA = ','
  # A semicolon ';' to be used e.g. in #gsub to optimize performance
  SEMICOLON = ';'
  # An empty string '' to be used e.g. in #gsub to optimize performance
  EMPTY = ''

  # read arguments provided at invocation
  # :call-seq:
  #   params => infile, Result, other_params
  #
  # Result methods are #cols, #col_count, #row_count, #sample_row
  def params

    script = ARGV.shift
    method = ARGV.shift
    infile = ARGV.shift

    if infile.nil?
      STDERR.puts "You must provide an input file"
      exit -1
    elsif !File.exists? infile
      STDERR.puts "#{infile} does not exist. You must provide a valid input file"
      exit -1
    end

    if ARGV.empty?
      print "#{method}(#{infile})"
    else
      print "#{method}(#{infile}, #{ARGV.join(', ')})"
    end

    puts; print "Analyzing #{infile}..."

    result = Sycsvpro::Analyzer.new(infile).result
    puts; print "> #{result.col_count} cols | #{result.row_count} rows"

    [infile, result, ARGV].flatten

  end

  # Delete obsolete files
  # :call-seq:
  #   clean_up(%w{ file1 file2 }) -> nil
  def clean_up(files)
    puts; print "Cleaning up directory..."

    files.each { |file| File.delete(file) }
  end
  
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

  # Remove leading and trailing " and spaces as well as reducing more than 2 
  # spaces between words from csv values. Replace ; with , from values as ; 
  # is used as value separator
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

  # Retrieves the values scanned by a COMMA_SPLITTER_REGEX
  def split_by_comma_regex(values)
    values.scan(COMMA_SPLITTER_REGEX).flatten.each.
      collect { |h| h.gsub(/BEGIN|END/, "") }
  end

  # Checks if the string represents an integer if so returns the integer 
  # otherwise nil
  def is_integer?(value)
    return value.
      gsub(COMMA_POINT_SPACE_REGEX, EMPTY) if !(value =~ INTEGER_REGEX).nil?
  end

  # Checks if the string represents a float and in case it is a float returns
  # the float value otherwise nil
  #   "1.5" -> 1.5
  #   "1."  -> 1.0
  def is_float?(value, decimal_separator = POINT)
    if decimal_separator == POINT
      return value.
        gsub(COMMA_SPACE_REGEX, EMPTY) if !(value =~ DECIMAL_POINT_REGEX).nil?
    else
      return value.
        gsub(POINT_SPACE_REGEX, EMPTY).
        gsub(COMMA, POINT) if !(value =~ DECIMAL_COMMA_REGEX).nil?
    end
  end

  # Converts a string to a numeric if the string represents a numerical value
  def str2num(value, decimal_separator = POINT)
    case 
    when v = is_integer?(value)
      v.to_i
    when v = is_float?(value, decimal_separator)
      v.to_f
    else
      value
    end 
  end

  private

    # Assigns values to keys that are used in rows and yielded to the block
    def extract_values(values, key, position)
      return values[position]            if key =~ /column$/
      return values.values_at(*position) if key =~ /columns$/
    end
end
