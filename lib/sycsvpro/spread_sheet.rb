require_relative 'not_available'

module Sycsvpro

  # A spread sheet is used to do column and row wise calculations between
  # spread sheets. The calculations can be *, /, + and - where the operations
  # are conducted between corresponding columns and rows. It is not as with
  # matrix operations.
  #
  # Example:
  #           [0] [1]          [0] [1]
  #   A = [0]   1   2  B = [0]   5   6 
  #       [1]   3   4      [1]   7   8
  #
  #                 [0*0]  [1*1]
  #   A * B = [0*0]     5     12  
  #           [1*1]    21     32
  #
  # If spread sheets are not the same size then the operation is looping through
  # the smaller spread sheets values
  #
  # Example:
  #           [0] [1]          [0]          [0]
  #   A = [0]   1   2  B = [0]   5  C = [0]   8
  #       [1]   3   4      [1]   7
  #
  #                 [0*0]  [1*1]
  #   A * B = [0*0]     5     35
  #           [1*1]    21     28
  #
  #                 [0*0]  [1*0]
  #   A * C = [0*0]     8     16
  #           [1*0]    24     32
  class SpreadSheet

    # rows of the spread sheet
    attr_accessor :rows
    # options of the spread sheet
    attr_accessor :opts
    # row labels
    attr_accessor :row_labels
    # column labels
    attr_accessor :col_labels

    # Creates a new spread sheet with rows and optional options.
    # 
    #   SpreadSheet.new([A,1,2], [B,3,4], rlabel: true, clabel: false)
    #
    # rlabel: first column of the row contains labels if true
    # clabel: first row are labels if true
    #
    # Creates a spread sheet with row labels 'A', 'B' and no column labels
    #       [0] [1]
    #   [A]   1   2
    #   [B]   3   4
    #
    #   SpreadSheet.new(['One','Two'],['A',1,2],['B',3,4], 
    #                   rlabel = true, 
    #                   clabel = true)
    #
    # Creates a spread sheet with row and column labels
    #
    #       [One] [Two]
    #   [A]     1     2
    #   [B]     3     4
    #
    # It is also possible to specify row and column labels explicit
    #
    #   SpreadSheet.new([1,2],[3,4], row_labels: ['A','B'], 
    #                                col_labels: ['One','Two'])
    def initialize(*rows)
      opts = rows.pop if rows.last.is_a?(::Hash)
      @opts = opts || {}
      rows = rows_from_params(@opts) if rows.empty?
      check_validity_of(rows)
      @row_labels, @col_labels = create_labels(rows)
      @rows = rows
    end

    # Returns the dimension [rows, columns] of the spread sheet
    #   SpreadSheet.new([1,2,3], [4,5,6]).dim -> [2,3]
    def dim
      [nrows, ncols]
    end

    # Returns the size of the spread sheet, that is the count of elements
    def size
      nrows * ncols
    end

    # Returns the number of rows
    def nrows
      rows.size
    end

    # Returns the number of columns
    def ncols
      rows[0].size
    end

    # Swaps rows and columns and returns new spread sheet with result
    def transpose
      SpreadSheet.new(*rows.transpose, row_labels: col_labels, 
                                       col_labels: row_labels)
    end

    # Returns a subset of the spread sheet and returns a new spread sheet with
    # the result and the corresponding row and column labels
    def [](*range)
      r, c = range
      r ||= 0..(nrows-1)
      c ||= 0..(ncols-1)
 
      row_selection = rows.values_at(*r)
      col_selection = []

      if rows_are_arrays?(row_selection)
        row_selection.each do |row|
          values = row.values_at(*c)
          col_selection << (values.respond_to?(:to_ary) ? values : [values])
        end 
      else
        col_selection << row_selection[*c]
      end

      SpreadSheet.new(*col_selection, 
                      row_labels: row_labels.values_at(*r),
                      col_labels: col_labels.values_at(*c))
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
      return false unless other.instance_of?(SpreadSheet)
      return false unless dim == other.dim
      row_count, col_count = dim
      0.upto(row_count - 1) do |r|
        0.upto(col_count - 1) do |c|
          return false unless rows[r][c] == other.rows[r][c]
        end
      end  
      true
    end
    
    # Yields each column
    def each_column
      0.upto(ncols-1) { |i| yield self[nil,i] }
    end

    # Collects the operation on each column and returns the result in an array
    def column_collect(&block)
      result = []
      0.upto(ncols-1) { |i| result << block.call(self[nil,i]) }
      result
    end

    # Prints the spread sheet in a matrix with column labels and row labels. If
    # no labels are available the column number and row number is printed
    def to_s
      #col_label_size = ncols.to_s.size
      col_label_size = col_labels.collect { |c| c.to_s.size }.max
      #row_label_size = nrows.to_s.size
      row_label_size = row_labels.collect { |c| c.to_s.size }.max
      col_size = [rows.flatten.collect { |c| c.to_s.size }.max, 
                  col_label_size + 2                            ].max + 1 

      print(sprintf("%#{row_label_size + 2}s", " "))
      #0.upto(ncols - 1) { |i| print(sprintf("%#{col_size}s", "[#{i}]")) }
      col_labels.each { |l| print(sprintf("%#{col_size}s", "[#{l}]")) }
      puts

      rows.each_with_index do |row, i|
        #print(sprintf("[%#{row_label_size}s]", i))
        print(sprintf("[%#{row_label_size}s]", row_labels[i]))
        row.each { |c| print(sprintf("%#{col_size}s", c)) }
        puts
      end
    end
    
    private

      # Creates rows from provided array or file. If array doesn't provide 
      # equal column sizes the array is extended with NotAvailable values
      def rows_from_params(opts)
        col_count = opts[:cols] 
        row_count = opts[:rows]
        
        size = row_count * col_count if row_count && col_count

        rows = []

        if values = opts[:values] 
          if size
            values += [NotAvailable] * (size - values.size)
          elsif col_count
            values += [NotAvailable] * ((col_count - values.size) % col_count)
          elsif row_count
            values += [NotAvailable] * ((row_count - values.size) % row_count)
            col_count = values.size / row_count
          else
            col_count = Math.sqrt(values.size).ceil
            values += [NotAvailable] * ((col_count - values.size) % col_count)
          end
          values.each_slice(col_count) { |row| rows << row }
        elsif opts[:file]
          File.readlines(opts[:file]).each do |line| 
            row = line.split(';')
            rows << row.collect { |v| v.strip.empty? ? NotAvailable : v.chomp }
          end
        end

        rows
      end

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
        offset = opts[:c] ? 1 : 0
        return true if rows.size == 1 + offset
        (0 + offset).upto(rows.size - 2) do |i| 
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

      def create_labels(rows)
        if opts[:c]
          col_labels = extract_col_labels(rows)
        end
        if opts[:r]
          row_labels = extract_row_labels(rows)
        end

        if opts[:row_labels]
          row_labels = opts[:row_labels]
          opts[:r] = true
        end
        if opts[:col_labels]
          col_labels = opts[:col_labels]
          opts[:c] = true
        end

        if opts[:c]
          if col_labels.size > rows[0].size
            col_labels = col_labels[col_labels.size - rows[0].size, 
                                    rows[0].size]
          else
            col_labels = col_labels + (0..rows[0].size-1).to_a[col_labels.size, 
                                                               rows[0].size] 
          end
        end

        if opts[:r]
          if row_labels.size > rows.size
            row_labels = row_labels[row_labels.size - rows.size, 
                                    rows.size]
          else
            row_labels = row_labels + (0..rows.size-1).to_a[row_labels.size, 
                                                               rows.size] 
          end
        end

        row_labels = (0..rows.size-1).to_a    unless row_labels
        col_labels = (0..rows[0].size-1).to_a unless col_labels
        [row_labels, col_labels]
      end

      def extract_col_labels(rows)
        col_labels = rows.shift
      end

      def extract_row_labels(rows)
        row_labels = []
        rows.each { |row| row_labels << row.shift }
        row_labels
      end

      # Coerces a number or an array to a spread sheet
      def coerce(value)
        return SpreadSheet.new([value]) if value.is_a?(Numeric)
        return SpreadSheet.new(value)   if value.is_a?(Array)
      end

      # Conducts the calculation of this spread sheet with the provided value 
      # based on the operator. It s is a number or an array it is coerced into
      # a spread sheet
      def process(operator, s)
        s = coerce(s) || s
        raise "operand needs to be a SpreadSheet, Numeric or Array" unless s.is_a?(SpreadSheet)
        result = []
        rlabel = []
        clabel = []
        s1_row_count, s1_col_count = dim
        s2_row_count, s2_col_count = s.dim
        row_count = [s1_row_count, s2_row_count].max
        col_count = [s1_col_count, s2_col_count].max
        0.upto(row_count - 1) do |r|
          r1 = r % s1_row_count
          r2 = r % s2_row_count
          rlabel << "#{row_labels[r1]}#{operator}#{s.row_labels[r2]}"
          element = []
          0.upto(col_count - 1) do |c|
            c1 = c % s1_col_count
            c2 = c % s2_col_count
            clabel << "#{col_labels[c1]}#{operator}#{s.col_labels[c2]}"
            element << rows[r1][c1].send(operator, s.rows[r2][c2])
          end
          result << element
        end
        SpreadSheet.new(*result, row_labels: rlabel, col_labels: clabel)
      end

  end

end
