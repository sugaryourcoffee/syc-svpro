require 'sycsvpro/merger.rb'

module Sycsvpro

  describe Merger do

    before do
      @file1   = File.join(File.dirname(__FILE__), "files/merge1.csv")
      @file2   = File.join(File.dirname(__FILE__), "files/merge2.csv")
      @outfile = File.join(File.dirname(__FILE__), "files/merged.csv")
    end

    it "should merge two files" do
      header = ",2010,2011,2012,2014"

      Sycsvpro::Merger.new(outfile: @outfile,
                           files:   "#{@file1},#{@file2}",
                           header:  header).execute

      result = [ ";2010;2011;2012;2014",
                 "SP;20;30;40;60",
                 "RP;30;40;50;70",
                 "MP;40;50;60;80",
                 "NP;50;60;70;90",
                 "M;m1;m2;m3",
                 "N;n1;n2;n3",
                 "O;o1;;o3", ]

      rows = 0

      File.open(@outfile).each_with_index do |row, index|
        row.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

  end

end
