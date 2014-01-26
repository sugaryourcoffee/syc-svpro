require_relative 'filter'

module Sycsvpro

  class Extractor

    attr_reader :in_file, :out_file, :rows, :cols, :row_filter, :col_filter

    def initialize(in_file, out_file, rows, cols)
      @in_file  = in_file
      @out_file = out_file
      @rows     = rows
      @cols     = cols
      @row_filter = Filter.new(rows)
      @col_filger = Filter.new(cols)
    end

    def extract
      File.open(out_file, 'w') do |o|
        File.new(in_file, 'r').each_with_index do |line, index|
          extraction = extract_values_from line, index
          o.puts extraction unless extraction.nil?
        end
      end
    end

    private

      def extract_values_from(line, index)
        return nil if line.chomp.empty?
        puts row_filter.process(line)
      end

  end

end
