require 'sycsvpro/inserter'

module Sycsvpro

  describe Inserter do
    
    before do
      @in_file = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
      @insert_file = File.join(File.dirname(__FILE__), "files/insert.csv")
    end

    it "should insert rows to file" do
      inserter = Inserter.new(infile: @in_file, outfile: @out_file, insert: @insert_file)

      inserter.execute

      result = [ ";H1;H2", "sum;=sum(b3:b4);=sum(c3:c4)", ";1;2", ";3;4",
                 "customer;contract-number;expires-on;machine;product1;product2",
                 "Fink;1234;20.12.2015;f1;con123;dri222",
                 "Haas;3322;1.10.2011;h1;con332;dri111",
                 "Gent;4323;1.3.2014;g1;con123;dri111",
                 "Fink;1234;30.12.2016;f2;con333;dri321",
                 "Rank;3232;\"1.5.2013\";r1;con332;dri321",
                 "Klig;4432;;k1;con332;dri222",
                 "fink;1234;;f3;con332;dri321",
               ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

  end

end
