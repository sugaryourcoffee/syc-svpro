# Operating csv files
module Sycsvpro

  # Holds the analytics of the file
  Result = Struct.new(:cols, :col_count, :row_count, :sample_row)

  # Analyzes the file structure
  class Analyzer

    # File that is analyzed
    attr_reader :file

    # Creates a new analyzer
    def initialize(file)
      @file = file
    end

    # Analyzes the file and returns the result
    def result
      rows = File.readlines(file)

      result = Result.new
      unless rows.empty?
        row_number = 0
        row_number += 1 while rows[row_number].chomp.empty?

        result.cols       = rows[row_number].chomp.split(';')
        result.col_count  = result.cols.size

        row_number += 1
        row_number += 1 while rows[row_number].chomp.empty?

        result.row_count  = rows.size - 1
        result.sample_row = rows[row_number].chomp
      end

      result
    end
  end
end
