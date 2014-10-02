module Sycsvpro

  class SpreadSheet

    attr_accessor :rows

    def initialize(*rows)
      check_validity_of(rows)
      @rows = rows
    end

    # Returns the dimension [rows, columns] of the spread sheet
    #   SpreadSheet.new([1,2,3], [4,5,6]).dim -> [2,3]
    def dim
      [rows.size, rows[0].size]
    end

    # Multiplies two spreadsheets column by column and returns a new spread
    # sheet with the result
    #   1 2 3   3 2 1    3  4  3
    #   4 5 6 * 6 5 4 = 24 25 24
    #   7 8 9   9 8 7   63 64 63
    def *(s)
      process("*", s)
    end

    # Divides two spreadsheets column by column and returns a new spread
    # sheet with the result
    #   1 2 3   3 2 1   1/3 1  3
    #   4 5 6 / 6 5 4 = 2/3 1 6/4
    #   7 8 9   9 8 7   7/9 1 9/7
    def /(s)
      process("/", s)
    end

    # Adds two spreadsheets column by column and returns a new spread
    # sheet with the result
    #   1 2 3   3 2 1    4  4  4
    #   4 5 6 + 6 5 4 = 10 10 10 
    #   7 8 9   9 8 7   16 16 16
    def +(s)
      process("+", s)
    end

    # Subtracts two spreadsheets column by column and returns a new spread
    # sheet with the result
    #   1 2 3   3 2 1   -2 0 2
    #   4 5 6 - 6 5 4 = -2 0 2
    #   7 8 9   9 8 7   -2 0 2
    def -(s)
      process("-", s)
    end

    # Compares if two spread sheets are equal. Two spread sheets are equal
    # if the spread sheets A and B are equal if Aij = Bij, that is elements at
    # the same position are equal
    def ==(other)
      return false unless dim == other.dim
      row_count, col_count = dim
      0.upto(row_count - 1) do |r|
        0.upto(col_count - 1) do |c|
          return false unless rows[r][c] == other.rows[r][c]
        end
      end  
      true
    end
    
    private

      # Checks whether the rows are valid, that is
      #   * same size
      #   * not nil
      #   * at least one row
      def check_validity_of(rows)
        raise "rows need to be arrays"           if !rows_are_arrays?(rows)
        raise "needs at least one row"           if rows.empty?
        raise "rows must be of same column size" if !same_column_size?(rows)
      end

      # Checks whether all rows have the same column size. Returns true if
      # all columns have the same column size
      def same_column_size?(rows)
        return true if rows.size == 1
        0.upto(rows.size - 2) do |i| 
          return false unless rows[i].size == rows[i+1].size
        end
        true
      end

      # Checks whether the rows are provided as arrays. If a non array element
      # is found false is returned otherwise true
      def rows_are_arrays?(rows)
        rows.each { |row| return false unless row.respond_to?(:to_ary) }
        true
      end

      def process(operator, s)
        result = []
        row_count, col_count = dim
        0.upto(row_count - 1) do |r|
          element = []
          0.upto(col_count - 1) do |c|
            element << rows[r][c].send(operator, s.rows[r][c])
          end
          result << element
        end
        SpreadSheet.new(*result)
      end

  end

end
