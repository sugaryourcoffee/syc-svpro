require 'sycsvpro/spread_sheet'

module Sycsvpro

  describe SpreadSheet do

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

    it "should check whether two spread sheets are equal" do
      s1 = SpreadSheet.new([1,2,3], [4,5,6])
      (s1 == s1).should be_true
      s2 = SpreadSheet.new([3,2,1], [6,5,4])
      (s1 == s2).should be_false
    end

    it "should return the dimension of a spreadsheet" do
      s1 = SpreadSheet.new([1,2,3], [3,4,5])
      s1.dim.should eq [2,3]
    end

    it "should multiply two spread sheets" do
      v1 = SpreadSheet.new([1,2],[3,4])
      v2 = SpreadSheet.new([5,6],[7,8])
      v3 = SpreadSheet.new([5,12],[21,32])
      (v1 * v2).should eq v3
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

    it "should multiply a column vector with each column of a spread sheet"

  end

end

