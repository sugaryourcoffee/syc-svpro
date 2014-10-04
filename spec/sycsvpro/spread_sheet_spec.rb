require 'sycsvpro/spread_sheet'

module Sycsvpro

  describe SpreadSheet do

    # Creation of spread sheets
    it "should ensure all rows have the same column size" do
      expect { SpreadSheet.new([1,2], [3,4,5]) }.to raise_error(RuntimeError,
                                             "rows must be of same column size")
    end

    it "should not accept non arrays as rows" do
      expect { SpreadSheet.new("abc", "abc") }.to raise_error(RuntimeError, 
                                                     "rows need to be arrays")
    end

    it "should require rows" do
      expect { SpreadSheet.new() }.to raise_error(RuntimeError, 
                                                  "needs at least one row")
    end

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

    # Spread sheets with column and row labels
  
    it "should return provided row and column labels" do
      v1 = SpreadSheet.new(['X','Y'], ['A',1,2],['B',3,4], r: true, c: true)
      v1.opts[:r].should be_true
      v1.opts[:c].should be_true
      v1.row_labels.should eq ['A','B']
      v1.col_labels.should eq ['X','Y']
    end

    it "should multiply spread sheets with row labels" do
    #  v1 = SpreadSheet.new(['A', 1,2],['B', 3,4], rlable: true)
    #  v2 = SpreadSheet.new([5,6],[7,8])
    #  v3 = SpreadSheet.new(['A', 5, 12], ['B', 21, 32])
    #  (v1 * v2).should eq v3
    end

    it "should multiply spread sheets with column labels"

    it "should multiply spread sheets with row and column labels"
  end

end

