require 'sycsvpro/aggregator'

module Sycsvpro

  describe Aggregator do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should aggregate single column values" do
      aggregator = Aggregator.new(infile: @in_file, outfile: @out_file, rows: "1-10",
                                  cols: "0", sum: "Total:1,Machines", headerless: true)

      aggregator.execute

      result = [ ";Machines",
                 "Total;7",
                 "Fink;2",
                 "Haas;1",
                 "Gent;1",
                 "Rank;1",
                 "Klig;1",
                 "fink;1" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

    it "should aggregate multiple column values" do
      aggregator = Aggregator.new(infile: @in_file, outfile: @out_file, rows: "0-10",
                            cols: "0,1", sum: "Total:1,Machines", headerless: false)
  
      aggregator.execute

      result = [ "customer;contract-number;Machines",
                 "Total;;7",
                 "Fink;1234;2",
                 "Haas;3322;1",
                 "Gent;4323;1",
                 "Rank;3232;1",
                 "Klig;4432;1",
                 "fink;1234;1" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end
    
  end

end
