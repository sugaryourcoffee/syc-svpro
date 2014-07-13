require 'sycsvpro/merger.rb'

module Sycsvpro

  describe Merger do

    before do
      @file1   = File.join(File.dirname(__FILE__), "files/merge1.csv")
      @file2   = File.join(File.dirname(__FILE__), "files/merge2.csv")
      @file3   = File.join(File.dirname(__FILE__), "files/merge3.csv")
      @file4   = File.join(File.dirname(__FILE__), "files/merge4.csv")
      @outfile = File.join(File.dirname(__FILE__), "files/merged.csv")
    end

    it "should merge two files" do
      header = "2010,2011,2012,2014"
      key = "0,0"
      source_header = "(\\d{4}),(\\d{4})"

      Sycsvpro::Merger.new(outfile:       @outfile,
                           files:         "#{@file1},#{@file2}",
                           header:        header,
                           key:           key,
                           source_header: source_header).execute

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

    it "should merge two files with differnt key columns in the middle" do
      header = "2010,2011,2012,2014"
      key = "0,3"
      source_header = "(\\d{4}),(\\d{4})"

      Sycsvpro::Merger.new(outfile:       @outfile,
                           files:         "#{@file1},#{@file2}",
                           header:        header,
                           key:           key,
                           source_header: source_header).execute

      result = [ ";2010;2011;2012;2014",
                 "SP;20;30;40;60",
                 "RP;30;40;50;70",
                 "MP;40;50;60;80",
                 "NP;50;60;70;90",
                 "MO;m1;m2;m3",
                 "NO;n1;n2;n3",
                 "OO;o1;;o3", ]

      rows = 0

      File.open(@outfile).each_with_index do |row, index|
        row.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should merge two files with differnt key columns at the end" do
      header = "2010,2011,2012,2014"
      key = "0,6"
      source_header = "(\\d{4}),(\\d{4})"

      Sycsvpro::Merger.new(outfile:       @outfile,
                           files:         "#{@file1},#{@file2}",
                           header:        header,
                           key:           key,
                           source_header: source_header).execute

      result = [ ";2010;2011;2012;2014",
                 "SP;20;30;40;60",
                 "RP;30;40;50;70",
                 "MP;40;50;60;80",
                 "NP;50;60;70;90",
                 "MI;m1;m2;m3",
                 "NI;n1;n2;n3",
                 "OI;o1;;o3", ]

      rows = 0

      File.open(@outfile).each_with_index do |row, index|
        row.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should merge two files without key columns" do
      header = "2010,2011,2012,2014"
      source_header = "(\\d{4}),(\\d{4})"

      Sycsvpro::Merger.new(outfile:       @outfile,
                           files:         "#{@file4},#{@file3}",
                           header:        header,
                           source_header: source_header).execute

      result = [ "2010;2011;2012;2014",
                 "20;30;40;60",
                 "30;40;50;70",
                 "40;50;60;80",
                 "50;60;70;90",
                 "m1;m2;m3",
                 "n1;n2;n3",
                 "o1;;o3", ]

      rows = 0

      File.open(@outfile).each_with_index do |row, index|
        row.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should merge two files key columns in one file only" do
      header = "2010,2011,2012,2014"
      key = "0"
      source_header = "(\\d{4}),(\\d{4})"

      Sycsvpro::Merger.new(outfile:       @outfile,
                           files:         "#{@file1},#{@file3}",
                           header:        header,
                           key:           key,
                           source_header: source_header).execute

      result = [ ";2010;2011;2012;2014",
                 "SP;20;30;40;60",
                 "RP;30;40;50;70",
                 "MP;40;50;60;80",
                 "NP;50;60;70;90",
                 ";m1;m2;m3",
                 ";n1;n2;n3",
                 ";o1;;o3", ]

      rows = 0

      File.open(@outfile).each_with_index do |row, index|
        row.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should merge two files key columns in two files of three only" do
      header = "2010,2011,2012,2014"
      key = "0, ,0"
      source_header = "(\\d{4}),(\\d{4}),(\\d{4})"

      Sycsvpro::Merger.new(outfile:       @outfile,
                           files:         "#{@file1},#{@file3},#{@file2}",
                           header:        header,
                           key:           key,
                           source_header: source_header).execute

      result = [ ";2010;2011;2012;2014",
                 "SP;20;30;40;60",
                 "RP;30;40;50;70",
                 "MP;40;50;60;80",
                 "NP;50;60;70;90",
                 ";m1;m2;m3",
                 ";n1;n2;n3",
                 ";o1;;o3",
                 "M;m1;m2;m3",
                 "N;n1;n2;n3",
                 "O;o1;;o3" ]

      rows = 0

      File.open(@outfile).each_with_index do |row, index|
        row.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

  end

end
