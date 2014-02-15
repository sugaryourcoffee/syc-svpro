require 'sycsvpro/extractor.rb'

module Sycsvpro

  describe Extractor do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should extract rows and columns" do
      extractor = Extractor.new(infile: @in_file, outfile: @out_file, rows: "2-4", cols: "1,3")

      extractor.extract

      result = ["3322;h1", "4323;g1", "3342;f2"]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

  end

end
