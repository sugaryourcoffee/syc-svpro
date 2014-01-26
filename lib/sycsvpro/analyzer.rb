module Sycsvpro

  Result = Struct.new(:cols, :col_count, :row_count, :sample_row)

  class Analyzer

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def result
      rows = File.readlines(file)

      result = Result.new
      unless rows.empty?
        row_number = 0
        row_number += 1 while rows[row_number].chomp.empty?

        result.cols       = rows[row_number].split(';')
        result.col_count  = result.cols.size

        row_number += 1
        row_number += 1 while rows[row_number].chomp.empty?

        result.row_count  = rows.size - 1
        result.sample_row = rows[row_number]
      end

      result
    end
  end
end
