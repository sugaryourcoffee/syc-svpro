require 'sycsvpro/mapper.rb'

module Sycsvpro

  describe Mapper do

    before do
      @in_file  = File.join(File.dirname(__FILE__), "files/in.csv")
      @in_file5 = File.join(File.dirname(__FILE__), "files/in5.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
      @mappings = File.join(File.dirname(__FILE__), "files/mappings")
    end

    it "should map values to new values in all columns" do
      mapper = Mapper.new(infile:  @in_file, 
                          outfile: @out_file, 
                          rows:    "0-7",
                          mapping: @mappings)

      mapper.execute

      result = [ "customer;contract-number;expires-on;machine;product1;product2",
                 "Fink;1234;20.12.2015;f1;control123;drive222",
                 "Haas;3322;1.10.2011;h1;control332;drive111",
                 "Gent;4323;1.3.2014;g1;control123;drive111",
                 "Fink;1234;30.12.2016;f2;control333;drive321",
                 "Rank;3232;1.5.2013;r1;control332;drive321",
                 "Klig;4432;;k1;control332;drive222",
                 "fink;1234;;f3;control332;drive321" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

    it "should map values to new values on specified columns only" do
      mapper = Mapper.new(infile:  @in_file,
                          outfile: @out_file,
                          rows:    "0-7",
                          cols:    "4",
                          mapping: @mappings).execute

      result = [ "customer;contract-number;expires-on;machine;product1;product2",
                 "Fink;1234;20.12.2015;f1;control123;dri222",
                 "Haas;3322;1.10.2011;h1;control332;dri111",
                 "Gent;4323;1.3.2014;g1;control123;dri111",
                 "Fink;1234;30.12.2016;f2;control333;dri321",
                 "Rank;3232;1.5.2013;r1;control332;dri321",
                 "Klig;4432;;k1;control332;dri222",
                 "fink;1234;;f3;control332;dri321" ]

      rows = 0

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size

    end

    it "should map values to new values where last column is empty" do
      mapper = Mapper.new(infile:  @in_file5,
                          outfile: @out_file,
                          cols:    "5",
                          mapping: @mappings).execute

      result = [ "customer;contract-number;expires-on;machine;product1;product2",
                 "Fink;1234;20.12.2015;f1;con123;drive222",
                 "Haas;3322;1.10.2011;h1;con332;drive111",
                 "Gent;4323;1.3.2014;g1;con123;drive111",
                 "Fink;1234;30.12.2016;f2;con333;drive321",
                 "Rank;3232;1.5.2013;r1;con332;drive321",
                 "Klig;4432;;k1;con332;drive222",
                 "fink;1234;;f3;con332;drive321",
                 "zink;8839;8.8.2018;z3;con332;" ]

      rows = 0

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size

    end

  end

end
