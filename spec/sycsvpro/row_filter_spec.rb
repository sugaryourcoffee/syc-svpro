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
      rows = "BEGINn1>50&&s2=='Ruby'||n3<10END"
      row_filter = Sycsvpro::RowFilter.new(rows)
      row_filter.process("a;49;Rub;9").should eq "a;49;Rub;9"
      row_filter.process("a;51;Ruby;11").should eq "a;51;Ruby;11"
      row_filter.process("a;49;Ruby;11").should be_nil
    end

    it "should filter rows on Ruby classes" do
      rows = "BEGINn1==50&&d2==Date.new(2014,6,16)||s3=~Regexp.new('[56789]\\d{2,}')END"
      row_filter = Sycsvpro::RowFilter.new(rows)
      row_filter.process("x;50;2014-06-16;99").should eq "x;50;2014-06-16;99"
    end

    it "should filter rows on row number filter and boolean filter" do
      rows = "1,3-4,BEGINn1==50&&d2<Date.new(2014,6,16)||s3=='Works?'END"
      row_filter = Sycsvpro::RowFilter.new(rows)
      row_filter.process("x;50;2014-06-15;Works?").should eq "x;50;2014-06-15;Works?"
      row_filter.process("x;50;2014-06-15;Works?", row: 1).should eq "x;50;2014-06-15;Works?"
    end

    it "should filter rows on boolean filter with brackets" do
      rows = "BEGINn1==50&&(d2<Date.new(2014,6,16)||s3=='Works?')END"
      row_filter = Sycsvpro::RowFilter.new(rows)
      row_filter.process("x;50;2014-6-15;Works?").should eq "x;50;2014-6-15;Works?"
      row_filter.process("x;49;2014-6-15;Works?").should be_nil
      row_filter.process("x;50;2014-6-17;Worx?").should be_nil
    end

    it "should fitler rows with ' in value" do
      rows = "BEGINn1!=50||n2=~'/\\d+/'||n2==\"Doesn't work\"END"
      row_filter = Sycsvpro::RowFilter.new(rows)
      row_filter.process("x;50;2;we").should be_nil
      row_filter.process("x;49;/\\d+/;\"Doesn't work\"").should eq "x;49;/\\d+/;Doesn't work"
    end

    it "should not filter rows with invalid syntax" do
      rows = "BEGINn1!=50||n2=~regex('\\d+')END"
      expect { Sycsvpro::RowFilter.new(rows) }.to raise_error
    end

  end

end

 
