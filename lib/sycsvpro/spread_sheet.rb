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
    #   SpreadSheet.new([A,1,2], [B,3,4], r: true, c: false)
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
    #                   r = true, 
    #                   c = true)
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
    #
    # Params
    # ======
    # r:          has row labels if true
    # c:          has column labels if true
    # row_labels: explicitly provides row labels
    # col_labels: explicitly provides column labels
    # values:     flat array with values
    # rows:       indicates the row count in combination with values param
    # cols:       indicates the col count in combination with values param
    # file:       file that contains values to create spread sheet with
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

    # Binds spread sheets column wise
    #
    #       1 2 3      10 20 30
    #   A = 4 5 6  B = 40 50 60
    #       7 8 9      70 80 90
    #
    #   C = SpeadSheet.bind_columns(A,B)
    #
    #       1 2 3 10 20 30
    #   C = 4 5 6 40 50 60
    #       7 8 9 70 80 90
    #
    # If the spread sheets have different row sizes the columns of the spread
    # sheet with fewer rows are filled with NotAvailable
    #
    #       1 2 3      10 20 30
    #   A = 4 5 6  B = 40 50 60
    #       7 8 9      
    #
    #   C = SpeadSheet.bind_columns(A,B)
    #
    #       1 2 3 10 20 30
    #   C = 4 5 6 40 50 60
    #       7 8 9 NA NA NA
    #
    # The column lables are also combined from the spread sheets and the row
    # labels of the spread sheet with the higher row count are used
    #
    # Returns the result in a new spread sheet
    def self.bind_columns(*sheets)
      row_count = sheets.collect { |s| s.nrows }.max
      binds = Array.new(row_count, [])
      0.upto(row_count - 1) do |r|
        sheets.each do |sheet|
          sheet_row = sheet.rows[r]
          binds[r] += sheet_row.nil? ? [NotAvailable] * sheet.ncols : sheet_row
        end
      end
      c_labels = sheets.collect { |s| s.col_labels }.inject(:+)
      r_labels = sheets.collect { |s| 
                   s.row_labels if s.row_labels.size == row_count 
                 }.first
      SpreadSheet.new(*binds, col_labels: c_labels, row_labels: r_labels)
    end

    # Binds spread sheets row wise
    #
    #       1 2 3      10 20 30
    #   A = 4 5 6  B = 40 50 60
    #       7 8 9      
    #
    #   C = SpeadSheet.bind_rows(A,B)
    #
    #        1  2  3 
    #        4  5  6
    #   C =  7  8  9
    #       10 20 30
    #       40 50 60
    #
    # If the spread sheets have different column sizes the columns of the spread
    # sheet with fewer columns are filled with NotAvailable
    #
    #       1 2 3      10 20
    #   A = 4 5 6  B = 40 50
    #       7 8 9      
    #
    #   C = SpeadSheet.bind_rows(A,B)
    #
    #        1  2  3
    #        4  5  6
    #   C =  7  8  9
    #       10 20 NA
    #       40 50 NA
    #
    # The row lables are also combined from the spread sheets and the column
    # labels of the spread sheet with the higher column count are used
    def self.bind_rows(*sheets)
      col_count = sheets.collect { |s| s.ncols }.max
      binds = []
      sheets.each do |sheet|
        binds << sheet.rows.collect { |r| 
                   r + [NotAvailable] * ((col_count - r.size) % col_count) 
                 }
      end
      r_labels = sheets.collect { |s| s.col_labels }.inject(:+)
      c_labels = sheets.collect { |s| s.col_labels if s.ncols == col_count }.first
      SpreadSheet.new(*binds.flatten(1), 
                      row_labels: r_labels, 
                      col_labels: c_labels)
    end

    # Returns the result in a new spread sheet
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

    # Renames the row and column labels
    #
    #   sheet.rename(rows: ['Row 1', 'Row 2'], cols: ['Col 1', 'Col 2'])
    #
    # If the provided rows and columns are larger than the spread sheet's rows
    # and columns then only the respective row and column values are used. If
    # the row and column labels are fewer than the respective row and column
    # sizes the old labels are left untouched for the missing new labels
    def rename(opts = {})
      if opts[:rows]
        opts[:rows] = opts[:rows][0,nrows]
        opts[:rows] += row_labels[opts[:rows].size, nrows]
      end

      if opts[:cols]
        opts[:cols] = opts[:cols][0,ncols]
        opts[:cols] += col_labels[opts[:cols].size, ncols]
      end

      @row_labels = opts[:rows] if opts[:rows]
      @col_labels = opts[:cols] if opts[:cols]
    end

    # Writes spread sheet to a file separated with ';'
    def write(file)
      File.open(file, 'w') do |out|
        out.puts ";#{col_labels.join(';')}"
        rows.each_with_index do |row, i| 
          out.puts "#{row_labels[i]};#{row.join(';')}"
        end
      end 
    end

    # Prints a summary of the spread sheet
    def summary
      puts "\nSummary"
      puts   "-------\n"
      puts "rows: #{nrows}, columns: #{ncols}, dimension: #{dim}, size: #{size}"
      puts
      puts "row labels:\n #{row_labels}"
      puts "column labels:\n #{col_labels}\n"
    end

    # Prints the spread sheet in a matrix with column labels and row labels. If
    # no labels are available the column number and row number is printed
    def to_s
      col_label_sizes = col_labels.collect { |c| c.to_s.size + 2 }
      row_label_size = row_labels.collect { |r| r.to_s.size + 2 }.max

      row_col_sizes = rows.transpose.collect { |r| r.collect { |c| c.to_s.size } } 

      i = -1
      col_sizes = col_label_sizes.collect do |s| 
        i += 1
        [row_col_sizes[i],s].flatten.max + 1
      end

      s = (sprintf("%#{row_label_size}s", " "))
      col_labels.each_with_index { |l,i| s << (sprintf("%#{col_sizes[i]}s", 
                                                       "[#{l}]"))           } 
      s << "\n"

      rows.each_with_index do |row, i|
        s << (sprintf("%#{row_label_size}s", "[#{row_labels[i]}]"))
        row.each_with_index { |c,j| s << (sprintf("%#{col_sizes[j]}s", c)) }
        s << "\n"
      end

      s
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
            rows << row.collect { |v| 
              v.strip.empty? ? NotAvailable : Float(v.chomp) rescue v.chomp 
            }
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
