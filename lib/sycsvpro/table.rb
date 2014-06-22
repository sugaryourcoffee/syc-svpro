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
    # the operations on columns
    attr_reader :formulae
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
    #                       header:  "Year,c6,c1",
    #                       key:     "c0=~/\\.(\\d{4})/,c6",
    #                       rows:    "1,2,BEGINn3>20END",
    #                       cols:    "o2:+c",
    #                       sum:     true).execute
    def initialize(options = {})
      @infile      = options[:infile]
      @outfile     = options[:outfile]
      @date_format = options[:df] || "%Y-%m-%d"
      @row_filter  = RowFilter.new(options[:rows], df: options[:df])
      @header      = Header.new(options[:header])
      @rows        = {}
      @keys        = options[:key].split(',')
      @cols        = options[:cols].split(',')
      @formulae    = {}
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
        rows.each do |key, row|
          line = [] << row[:key]
          header.clear_header_cols.each_with_index do |col, index|
            next if index < row[:key].size
            line << row[:cols][col]
          end
          out.puts line.flatten.join(';')
        end
      end
    end

    def create_key
      key = []
      @keys.each do |k|
        if value = eval(k)
          last_match = $1
          key << ((k =~ /^c\d+=~/) ? last_match : value)
        else
          key << ""
        end   
      end
      key
    end

    def create_row(key, line)
      # Value:+c1
      # Value:+n1,c2+c3:+n1
      row = rows[key] || rows[key] = { key: key, cols: Hash.new(0) }  
      @cols.each do |col|
        column, formula = col.split(':')
        column = eval(column) if column =~ /^c\d+[=~+]/
        row[:cols][column] = eval("#{row[:cols][column]}#{formula}")
      end
    end

    private

      # Casts a string to an integer or float depending whether the value has a 
      # decimal point
      def to_number(value)
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

  end

end

