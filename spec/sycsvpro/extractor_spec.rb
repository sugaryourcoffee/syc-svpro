require 'sycsvpro/extractor.rb'

module Sycsvpro

  describe Extractor do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should extract rows and columns" do
      extractor = Extractor.new(infile: @in_file, outfile: @out_file, rows: "2-4", cols: "1,3")

      extractor.execute

      result = ["3322;h1", "4323;g1", "1234;f2"]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

    it "should extract rows based on regex" do
      extractor = Extractor.new(infile: @in_file, outfile: @out_file, rows: "/dri3.*/")

      extractor.execute

      result = [ "Fink;1234;30.12.2016;f2;con333;dri321",
                 "Rank;3232;1.5.2013;r1;con332;dri321",
                 "fink;1234;;f3;con332;dri321" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

  end

end
