require 'sycsvpro/spread_sheet'

module Sycsvpro

  describe SpreadSheet do

    # Creation of spread sheets
    it "should ensure all rows have the same column size" do
      expect { SpreadSheet.new([1,2], [3,4,5]) }.to raise_error(RuntimeError,
                    "rows must be of same column size. Use equalize: true "+
                    "flag to fix.")
    end

    it "should not accept non arrays as rows" do
      expect { SpreadSheet.new("abc", "abc") }.to raise_error(RuntimeError, 
                                                     "rows need to be arrays")
    end

    it "should require rows" do
      expect { SpreadSheet.new() }.to raise_error(RuntimeError, 
                                                  "needs at least one row")
    end

    it "should be created from file" do
      file = File.join(File.dirname(__FILE__), "files/spread_sheet.csv")

      s1 = SpreadSheet.new(file: file, r: true, c: true)
      s2 = SpreadSheet.new(['Alpha', 'Beta', 'Gamma'],
                           ['A',1,2,3],['B',4,5,6],['C',7,8,9],
                           r: true, c: true)
      expect { s1 == s2 }
    end

    it "should be created from first n rows of file"

    it "should be created from last n rows of file"

    it "should be created from file with missing values" do
      file = File.join(File.dirname(__FILE__), "files/spread_sheet_na.csv")

      s1 = SpreadSheet.new(file: file, r: true, c: true)
      s2 = SpreadSheet.new(['Alpha', 'Beta', 'Gamma'],
                           ['A',NotAvailable,2,3],
                           ['B',4,5,NotAvailable],
                           ['C',7,NotAvailable,9],
                           r: true, c: true)
      expect { s1 == s2 }
    end

    it "should skip empty rows in file" do
      file = File.join(File.dirname(__FILE__), 
                       "files/spread_sheet_with_empty_rows.csv")

      s1 = SpreadSheet.new(file: file, r: true, c: true)
      s2 = SpreadSheet.new(['Alpha', 'Beta', 'Gamma'],
                           ['A',NotAvailable,2,3],
                           ['C',7,NotAvailable,9],
                           r: true, c: true)
      
      expect { s1 == s2 }.to be_true
    end

    it "should equalize column size through NA" do
      s1 = SpreadSheet.new([1,2,3],[4,5],[6,7,8,9],[10], equalize: true)
      s2 = SpreadSheet.new([1,2,3,NotAvailable],
                           [4,5,NotAvailable,NotAvailable],
                           [6,7,8,9],
                           [10,NotAvailable,NotAvailable,NotAvailable])
      s1.should eq s2
    end

    it "should equalize column size through NA with row and column labels" do
      s1 = SpreadSheet.new(['A','B'],
                           ['W',1,2,3],
                           ['X',4,5],
                           ['Y',6,7,8,9],
                           ['Z',10], 
                           r: true, c: true,
                           equalize: true)
      
      s2 = SpreadSheet.new(['A','B',2,3],['W',1,2,3,NotAvailable],
                           ['X',4,5,NotAvailable,NotAvailable],
                           ['Y',6,7,8,9],
                           ['Z',10,NotAvailable,NotAvailable,NotAvailable],
                           r: true, c: true)
      s1.should eq s2
    end

    it "should be created from flat array" do
      s1 = SpreadSheet.new(values: [1,2,3,4,5,6], cols: 2)
      s2 = SpreadSheet.new([1,2],[3,4],[5,6])
      s1.should eq s2
      s1 = SpreadSheet.new(values: [1,2,3,4,5,6], rows: 2)
      s2 = SpreadSheet.new([1,2,3],[4,5,6])
      s1.should eq s2
      s1 = SpreadSheet.new(values: [1,2,3,4,5,6], rows: 3, cols: 2)
      s2 = SpreadSheet.new([1,2],[3,4],[5,6])
      s1.should eq s2
      s1 = SpreadSheet.new(values: [1,2,3,4,5], rows: 2)
      s2 = SpreadSheet.new([1,2,3],[4,5,NotAvailable])
      s1.should eq s2
      s1 = SpreadSheet.new(values: [1,2,3,4,5], cols: 3)
      s2 = SpreadSheet.new([1,2,3],[4,5,NotAvailable])
      s1.should eq s2
     end

    # Writing of spread sheets

    it "should write to file" do
      file = File.join(File.dirname(__FILE__), "files/spread_sheet_out.csv")

      s1 = SpreadSheet.new(['A', 'B', 'C'],['I',1,2,3],['II',4,5,6], 
                           r: true, c: true)
      s1.write(file)
      Dir.glob(file).size.should eq 1
    end

    # Manipulating spread sheets

    it "should transpose rows and columns" do
      s1 = SpreadSheet.new(["C1","C2","C3"],['A',1,3,5],['B',7,11,13], r: true, c: true)
      s2 = SpreadSheet.new(['A','B'],['C1',1,7],['C2',3,11],['C3',5,13], r: true, c: true)
      expect { s1.tranpose == s2 }
    end

    it "should sort on columns"

    it "should filter rows on column values"

    it "should assign new values to rows and columns"

    it "should delete columns"

    it "should delete rows"
    
    # Information about spread sheets
    
    it "should return the dimension of a spreadsheet" do
      s1 = SpreadSheet.new([1,2,3], [3,4,5])
      s1.dim.should eq [2,3]
    end

    it "should return the row count" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6], [7,8,9])
      s1.nrows.should eq 3
    end

    it "should return the column count" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6], [7,8,9])
      s1.ncols.should eq 3
    end

    it "should return the size" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6], [7,8,9])
      s1.size.should eq 9
    end

    it "should return default row and column labels" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6], [7,8,9])
      s1.row_labels.should eq [0,1,2]
      s1.col_labels.should eq [0,1,2]
    end

    it "should check whether two spread sheets are equal" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6])
      (s1 == s1).should be_true
      s2 = SpreadSheet.new([3,2,1], [6,5,4])
      (s1 == s2).should be_false
    end

    # Subsetting spread sheets
    
    it "should retrieve rows based on row number" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6])
      s2 = SpreadSheet.new([4,5,6])
      s1[1,].should eq s2
      s1[nil,nil].should eq s1
    end

    it "should return columns based on column numbers" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6])
      s2 = SpreadSheet.new([3],[6])
      s1[nil,2].should eq s2
    end
 
    it "should return a subset of the table" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6])
      s2 = SpreadSheet.new([5,6])
      s1[1,1..2].should eq s2
      s1 = SpreadSheet.new([10,11,12], [13,14,15])
      s2 = SpreadSheet.new([11,12], [14,15])
      s1[nil,1..2].should eq s2
      s1 = SpreadSheet.new([16,17,18], [19,20,21])
      s2 = SpreadSheet.new([16,18], [19,21])
      s1[nil,[0,2]].should eq s2
    end

    it "should bind two spread sheets column wise" do
      s1 = SpreadSheet.new([10,11,12], [13,14,15])
      s2 = SpreadSheet.new([16,17,18], [19,20,21])

      s3 = SpreadSheet.bind_columns(s1,s2)
      result = SpreadSheet.new([10,11,12,16,17,18],[13,14,15,19,20,21])

      expect { s3 == result }
    end

    it "should bind two spread sheets with different row size column wise" do
      s1 = SpreadSheet.new([10,11,12], [13,14,15], [16,17,18])
      s2 = SpreadSheet.new([16,17,18], [19,20,21])

      s3 = SpreadSheet.bind_columns(s1,s2)
      result = SpreadSheet.new([10,11,12,16,17,18],[13,14,15,19,20,21],
                               [16,17,18,
                                NotAvailable,NotAvailable,NotAvailable])

      expect { s3 == result }.to be_true
      s3.should eq result
    end

    it "should bind two spread sheets row wise" do
      s1 = SpreadSheet.new([10,11,12], [13,14,15])
      s2 = SpreadSheet.new([16,17,18], [19,20,21])

      s3 = SpreadSheet.bind_rows(s1,s2)
      result = SpreadSheet.new([10,11,12],[13,14,15],[16,17,18],[19,20,21])

      expect { s3 == result }.to be_true
      s3.should eq result
    end

    it "should bind two spread sheets row wise with different column size" do
      s1 = SpreadSheet.new([10,11,12], [13,14,15])
      s2 = SpreadSheet.new([16,17], [19,20])

      s3 = SpreadSheet.bind_rows(s1,s2)
      result = SpreadSheet.new([10,11,12],[13,14,15],
                               [16,17,NotAvailable],[19,20,NotAvailable])

      expect { s3 == result }.to be_true
      s3.should eq result
    end

    # Calculating with spread sheets

    it "should multiply two spread sheets of same size" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([5,12],[21,32])
      (v1 * v2).should eq v3
    end

    it "should multiply two spread sheets of different size" do
      v1 = SpreadSheet.new([2],[4])
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([10,12],[28,32])
      (v1 * v2).should eq v3
      (v2 * v1).should eq v3

      v1 = SpreadSheet.new([2,3,4],[4,5,6])
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([10,18,20],[28,40,42])
      (v1 * v2).should eq v3
      (v2 * v1).should eq v3
    end

    it "should add two spread sheets" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([6,8],[10,12])
      (v1 + v2).should eq v3
    end

    it "should subtract two spread sheets" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([-4,-4],[-4,-4])
      (v1 - v2).should eq v3
    end

    it "should devide two spread sheets" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([1/5,2/6],[3/7,4/8])
      (v1 / v2).should eq v3
    end

    it "should work with numericals" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([2,4],[6,8])
      (v1 * 2).should eq v2 
    end

    it "should work with arrays" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([3,6],[9,8])
      expect { v1 * [3,2] == v2 }.to be_true
    end

    it "should multiply each column with all columns of a spread sheet" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([5,6],[7,8])

      result = []
      v1.each_column { |c| result << c*v2 } 

      #  1 2     5 6    5  6 10 12
      #  3 4     7 8   21 24 28 32

      v3 = SpreadSheet.new([5,6],[21,24])
      v4 = SpreadSheet.new([10,12],[28,32])
      result.should eq [v3,v4]
    end

    it "should collect the result of all multiplications" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([5,6],[7,8])

      result = v1.column_collect { |c| c * v2 }

      v3 = SpreadSheet.new([5,6],[21,24])
      v4 = SpreadSheet.new([10,12],[28,32])

      result.should eq [v3,v4]
    end

    # Spread sheets with column and row labels
  
    it "should create spread sheet with row labels" do
      v1 = SpreadSheet.new([1,2],[3,4], row_labels: ['A','B'])
      v1.opts[:r].should be_true
      v1.opts[:c].should be_false
      v1.row_labels.should eq ['A','B']
      v1.col_labels.should eq [0,1]
    end

    it "should create spread sheet with column labels" do
      v1 = SpreadSheet.new([1,2],[3,4], col_labels: ['X','Y'])
      v1.opts[:r].should be_false
      v1.opts[:c].should be_true
      v1.row_labels.should eq [0,1]
      v1.col_labels.should eq ['X','Y']
    end

    it "should create spread sheet with row and column labels" do
      v1 = SpreadSheet.new([1,2],[3,4], row_labels: ['A','B'], 
                                        col_labels: ['X','Y'])
      v1.opts[:r].should be_true
      v1.opts[:c].should be_true
      v1.row_labels.should eq ['A','B']
      v1.col_labels.should eq ['X','Y']
    end

    it "should create spread sheet with uncomplete row and column labels" do
      v1 = SpreadSheet.new([1,2,3],[3,4,5],[6,7,8], row_labels: ['A','B'], 
                                                    col_labels: ['X','Y'])
      v1.opts[:r].should be_true
      v1.opts[:c].should be_true
      v1.row_labels.should eq ['A','B',2]
      v1.col_labels.should eq ['X','Y',2]
    end

    it "should return provided row labels" do
      v1 = SpreadSheet.new(['A',1,2],['B',3,4], r: true)
      v1.opts[:r].should be_true
      v1.opts[:c].should be_false
      v1.row_labels.should eq ['A','B']
      v1.col_labels.should eq [0,1]
    end

    it "should return provided column labels" do
      v1 = SpreadSheet.new(['X','Y'],[1,2],[3,4], c: true)
      v1.opts[:r].should be_false
      v1.opts[:c].should be_true
      v1.row_labels.should eq [0,1]
      v1.col_labels.should eq ['X','Y']
    end

    it "should return provided row and column labels" do
      v1 = SpreadSheet.new(['X','Y'], ['A',1,2],['B',3,4], r: true, c: true)
      v1.opts[:r].should be_true
      v1.opts[:c].should be_true
      v1.row_labels.should eq ['A','B']
      v1.col_labels.should eq ['X','Y']
    end

    it "should fill missing labels with default labels" do
      v1 = SpreadSheet.new(['X','Y'], ['A',1,2,3],['B',3,4,5], r: true, c: true)
      v1.opts[:r].should be_true
      v1.opts[:c].should be_true
      v1.row_labels.should eq ['A','B']
      v1.col_labels.should eq ['X','Y',2]
    end

    it "should return provided row and column labels with row column label" do
      v1 = SpreadSheet.new(['Letter','X','Y'], ['A',1,2],['B',3,4], r: true, c: true)
      v1.opts[:r].should be_true
      v1.opts[:c].should be_true
      v1.row_labels.should eq ['A','B']
      v1.col_labels.should eq ['X','Y']
    end

    it "should rename row and column labels with same label count" do
      s1 = SpreadSheet.new([1,2,3,4],[5,6,7,8])
      s1.row_labels.should eq [0,1]
      s1.col_labels.should eq [0,1,2,3]

      s1.rename(rows: ['A','B'], cols: ['X','Ypsilon','Z','X1'])
      s1.row_labels.should eq ['A','B']
      s1.col_labels.should eq ['X','Ypsilon','Z','X1']
    end

    it "should rename row and column labels with different label count" do
      s1 = SpreadSheet.new([1,2,3,4],[5,6,7,8])
      s1.row_labels.should eq [0,1]
      s1.col_labels.should eq [0,1,2,3]

      s1.rename(rows: ['A'], cols: ['X','Ypsilon','Z'])
      s1.row_labels.should eq ['A',1]
      s1.col_labels.should eq ['X','Ypsilon','Z',3]
    end

    it "should create subset with row and column labels" do
      v1 = SpreadSheet.new(['Letter','X','Y'], ['A',1,2],['B',3,4], r: true, c: true)
      v2 = v1[nil, 1]
      v2.row_labels.should eq ['A', 'B']
      v2.col_labels.should eq ['Y'] 
    end

    it "should multiply spread sheets with row labels" do
      v1 = SpreadSheet.new(['A', 1,2],['B', 3,4], r: true)
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([5, 12], [21, 32])
      v4 = v1 * v2
      v4.should eq v3
      v4.row_labels.should eq ['A*0', 'B*1']
      v4.col_labels.should eq ['0*0','1*1']
    end

    it "should multiply spread sheets with column labels" do
      v1 = SpreadSheet.new(['X','Y'],[1,2],[3,4], c: true)
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([5, 12], [21, 32])
      v4 = v1 * v2
      v4.should eq v3
      v4.row_labels.should eq ['0*0','1*1']
      v4.col_labels.should eq ['X*0','Y*1']
    end

    it "should multiply spread sheets with row and column labels" do
      v1 = SpreadSheet.new(['X','Y'],['A', 1,2],['B', 3,4], r: true, c: true)
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([5, 12], [21, 32])
      v4 = v1 * v2
      v4.should eq v3
      v4.row_labels.should eq ['A*0', 'B*1']
      v4.col_labels.should eq ['X*0', 'Y*1']
    end

  end

end

