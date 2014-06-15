require 'sycsvpro/row_filter'

module Sycsvpro

  describe RowFilter do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should return row string when no filter is set" do
      row_filter = Sycsvpro::RowFilter.new(nil)
      row_filter.process("abc", row: 1).should eq "abc"
    end

    it "should filter rows on index" do
      rows = "1-5"
      row_filter = Sycsvpro::RowFilter.new(rows)
      row_filter.process("abc", row: 1).should eq "abc"
      row_filter.process("abc", row: 6).should be_nil 
    end

    it "should filter rows on regex" do
      rows = "1,\/\\d{2,}\/"
      row_filter = Sycsvpro::RowFilter.new(rows)
      row_filter.process("5;50;500", row: 1).should eq "5;50;500"
      row_filter.process("5;50;500", row: 2).should eq "5;50;500"
    end

    it "should filter rows on logical expression" do
      rows = "n1>50&&s2=='Ruby'||n3<10"
      row_filter = Sycsvpro::RowFilter.new(rows)
      row_filter.process("a;49;Rub;9").should eq "a;49;Rub;9"
      row_filter.process("a;51;Ruby;11").should eq "a;51;Ruby;11"
      row_filter.process("a;49;Ruby;11").should be_nil
    end

  end

end

 
