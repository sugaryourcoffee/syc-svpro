require 'sycsvpro/transposer'

module Sycsvpro

  describe Transposer do

    before do
      @infile  = File.join(File.dirname(__FILE__), 'files/in6.csv')
      @outfile = File.join(File.dirname(__FILE__), 'files/out.csv')
    end

    it "should transpose (change rows to columns) complete file" do
      Sycsvpro::Transposer.new(infile:  @infile,
                               outfile: @outfile).execute

      result = [ "Year;;2008;2009;2010",
                 "SP;10;5;2;3",
                 "RP;20;10;5;5",
                 "Total;30;15;5;10",
                 "SP-O;100;10;20;70",
                 "RP-O;40;20;10;10",
                 "O;140;10;30;100" ]

      rows = 0

      File.open(@outfile).each_with_index do |line, i|
        line.chomp.should eq result[i]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should transpose selected columns" do
      Sycsvpro::Transposer.new(infile:  @infile,
                               outfile: @outfile,
                               cols:    "0-2").execute

      result = [ "Year;;2008;2009;2010",
                 "SP;10;5;2;3",
                 "RP;20;10;5;5" ]

      rows = 0

      File.open(@outfile).each_with_index do |line, i|
        line.chomp.should eq result[i]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should transpose selected rows and columns" do
      Sycsvpro::Transposer.new(infile:  @infile,
                               outfile: @outfile,
                               rows:    "0,2-4",
                               cols:    "0-2").execute

      result = [ "Year;2008;2009;2010",
                 "SP;5;2;3",
                 "RP;10;5;5" ]

      rows = 0

      File.open(@outfile).each_with_index do |line, i|
        line.chomp.should eq result[i]
        rows += 1
      end

      rows.should eq result.size
    end


  end

end
