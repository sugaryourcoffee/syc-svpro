require_relative 'row_filter'
require_relative 'header'
require_relative 'dsl'
require 'date'

module Sycsvpro

  class Table

    include Dsl

    # infile contains the data that is operated on
    attr_reader :infile
    # outfile is the file where the result is written to
    attr_reader :outfile
    # filter that is used for rows
    attr_reader :row_filter
    # date format for date operations
    attr_reader :date_format
    # header of the outfile
    attr_reader :header
    # rows of the created table
    attr_reader :rows

    # Creates a new Table. Options expects :infile, :outfile, :rows and 
    # :columns. Optionally a header can be provided. The header can be 
    # supplemented with additional column names that are generated due to a 
    # arithmetic operation that creates new columns
    # :call-seq:
    #   Sycsvpro::Table.new(infile:  "in.csv",
    #                       outfile: "out.csv",
    #                       df:      "%d.%m.%Y",
    #                       rows:    "1,2,BEGINn3>20END",
    #                       header:  "Year,c6,c1",
    #                       key:     "c0=~/\\.(\\d{4})/,c6",
    #                       cols:    "Value:+n1,c2+c3:+n1",
    #                       nf:      "DE",
    #                       sum:     "TOP:Value,c2+c3").execute
    def initialize(options = {})
      @infile      = options[:infile]
      @outfile     = options[:outfile]
      @date_format = options[:df] || "%Y-%m-%d"
      @row_filter  = RowFilter.new(options[:rows], df: options[:df])
      @header      = Header.new(options[:header])
      @keys        = options[:key].split(',')
      @cols        = options[:cols].split(',')
      @number_format = options[:nf] || 'EN'
      prepare_sum_row options[:sum]
      @rows        = {}
    end

    # Retrieves the values from a row as the result of a arithmetic operation
    # with #eval
    def method_missing(id, *args, &block)
      return @columns[$1.to_i]            if id =~ /c(\d+)/
      return to_number(@columns[$1.to_i]) if id =~ /n(\d+)/
      return to_date(@columns[$1.to_i])   if id =~ /d(\d+)/
      super
    end

    # Executes the table and writes the result to the _outfile_
    def execute
      create_table_data
      write_to_file
    end

    # Create the table
    def create_table_data
      processed_header = false

      File.open(infile).each_with_index do |line, index|
        line = line.chomp

        next if line.empty?
        
        line = unstring(line).chomp

        header.process line, processed_header

        unless processed_header
          processed_header = true
          next
        end

        next if row_filter.process(line, row: index).nil?
        
        @columns = line.split(';')

        create_row(create_key, line)
      end

    end

    # Write table to _outfile_
    def write_to_file
      File.open(outfile, 'w') do |out|
        out.puts header.to_s
        out.puts create_sum_row if @sum_row_pos == 'TOP'
        rows.each do |key, row|
          line = [] << row[:key]
          header.clear_header_cols.each_with_index do |col, index|
            next if index < row[:key].size
            line << row[:cols][col]
          end
          out.puts line.flatten.join(';')
        end
        out.puts create_sum_row if @sum_row_pos == 'EOF'
      end
    end

    # Creates a key from the provided key pattern
    def create_key
      key = []
      @keys.each { |k| key << evaluate(k, "") }
      key
    end

    # Creates a table row based on the column pattern
    # Examples of column patterns
    # * Value:+n1             Adds content of column 1 to Value column
    # * Value:+n1,c2+c3:+n1   Creates a dynamic column and adds column 1 value
    # * c0=~/\\.(\\d{4})/:+n1 Creates dynamic column from regex and adds
    #                         column 1 value
    def create_row(key, line)
      row = rows[key] || rows[key] = { key: key, cols: Hash.new(0) }  
      @cols.each do |col|
        column, formula = col.split(':')
        column = evaluate(column) if column =~ /^c\d+[=~+]/
        previous_value = row[:cols][column]
        row[:cols][column] = eval("#{row[:cols][column]}#{formula}")
        add_to_sum_row(row[:cols][column] - previous_value, column)
      end
    end

    private

      # Casts a string to an integer or float depending whether the value has a 
      # decimal point
      def to_number(value)
        value = convert_to_en(value)
        return value.to_i unless value =~ /\./
        return value.to_f if     value =~ /\./ 
      end

      # Casts a string to a date
      def to_date(value)
        if value.nil? or value.strip.empty?
          nil
        else
          Date.strptime(value, date_format)
        end
      end

      # Localize the number to EN
      def convert_to_en(value)
        if @number_format == 'DE'
          value.gsub('.', '_').gsub(',', '.')
        else
          value
        end
      end

      # Evaluate a formula
      # Example invokation
      #     evaluate("n1+n2", 0)
      #     evaluate("c1+c2", "failed")
      #     evaluate("c0=~/\\.(\\d{4})/", "0")
      def evaluate(formula, fail_result = 0)
        if value = eval(formula)
          last_match = $1
          (formula =~ /^c\d+=~/) ? last_match : value
        else
          fail_result
        end   
      end

      def prepare_sum_row(pattern)
        return if pattern.nil? || pattern.empty?
        @sum_row_pos, sum_row_pattern = pattern.split(':')
        @sum_row_pos.upcase!
        @sum_row = Hash.new
        @sum_row_patterns = sum_row_pattern.split(',')
      end

      def add_to_sum_row(value, column)
        return unless @sum_row_patterns
        @sum_row_patterns.each do |pattern|
          if pattern =~ /^c\d+[=~+]/
            header_column = evaluate(pattern, "")
          else
            header_column = pattern
          end

          if header_column == column
            @sum_row[header_column] ||= 0
            @sum_row[header_column] += value
          end
        end
      end

      def create_sum_row
        line = []
        header.clear_header_cols.each_with_index do |col, index|
          line << @sum_row[col] || ""
        end
        line.flatten.join(';')
      end

  end

end

