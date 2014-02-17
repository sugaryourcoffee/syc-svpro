require 'sycsvpro/counter.rb'

module Sycsvpro

  describe Counter do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should count columns" do
      counter = Counter.new(infile: @in_file, outfile: @out_file, rows: "1-10", cols: "4,5", 
                            key: "0")

      counter.execute

      result = [ "customer;con123;con332;con333;dri111;dri222;dri321",
                 "Fink;1;0;1;0;1;1",
                 "Haas;0;1;0;1;0;0",
                 "Gent;1;0;0;1;0;0",
                 "Rank;0;1;0;0;0;1",
                 "Klig;0;1;0;0;1;0" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

    it "should count date coloms" do
      counter = Counter.new(infile: @in_file, outfile: @out_file, rows: "1-10", 
                            cols: "2:<1.1.2013,2:1.1.2013-31.12.2014,2:>31.12.2014", key: "0",
                            df: "%d.%m.%Y")

      counter.execute

      result = [ "customer;1.1.2013-31.12.2014;<1.1.2013;>31.12.2014",
                 "Fink;0;0;2",
                 "Haas;0;1;0",
                 "Gent;1;0;0",
                 "Rank;1;0;0" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

  end

end
