require 'sycsvpro/analyzer.rb'

module Sycsvpro

  describe Analyzer do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/in.csv")
    end

    it "should analyze infile" do
      analyzer = Analyzer.new(@in_file)
      result = analyzer.result
      result.cols.should =~ ['customer', 'contract-number', 'expires-on', 'machine', 
                             'product1', 'product2']
      result.col_count.should eq 6
      result.row_count.should eq 6
      result.sample_row.should eq "Fink;1234;20.12.2015;f1;con123;dri222"
    end

  end

end
