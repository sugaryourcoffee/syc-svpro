require 'sycsvpro/counter.rb'

module Sycsvpro

  describe Counter do

    before do
      @in_file       = File.join(File.dirname(__FILE__), "files/in.csv")
      @in_ibase_file = File.join(File.dirname(__FILE__), "files/ibase.csv")
      @out_file      = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should count columns" do
      counter = Counter.new(infile: @in_file, outfile: @out_file, rows: "1-10", cols: "4,5", 
                            key: "0:customer")

      counter.execute

      result = [ "customer;con123;con332;con333;dri111;dri222;dri321",
                 "Fink;1;0;1;0;1;1",
                 "Haas;0;1;0;1;0;0",
                 "Gent;1;0;0;1;0;0",
                 "Rank;0;1;0;0;0;1",
                 "Klig;0;1;0;0;1;0",
                 "fink;0;1;0;0;0;1" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

    it "should count date columns" do
      counter = Counter.new(infile: @in_file, outfile: @out_file, rows: "1-10", 
                            cols: "2:<1.1.2013,2:1.1.2013-31.12.2014,2:>31.12.2014", 
                            key: "0:customer", df: "%d.%m.%Y")

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

    it "should add a sum row" do
      counter = Counter.new(infile: @in_file, outfile: @out_file, rows: "1-10",
                          cols: "2:<1.1.2013,2:1.1.2013-31.12.2014,2:>31.12.2014", 
                          key: "0:customer", df: "%d.%m.%Y", sum: "Total:1")

      counter.execute

      result = [ "customer;1.1.2013-31.12.2014;<1.1.2013;>31.12.2014",
                 "Total;2;1;2",
                 "Fink;0;0;2",
                 "Haas;0;1;0",
                 "Gent;1;0;0",
                 "Rank;1;0;0" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

    it "should add a sum row and column" do
      counter = Counter.new(infile: @in_file, outfile: @out_file, rows: "1-10",
                          cols: "2:<1.1.2013,2:1.1.2013-31.12.2014,2:>31.12.2014", 
                          key: "0:customer", df: "%d.%m.%Y", sum: "Total:1,Sumsup")
      counter.execute

      result = [ "customer;1.1.2013-31.12.2014;<1.1.2013;>31.12.2014;Sumsup",
                 "Total;2;1;2;5",
                 "Fink;0;0;2;2",
                 "Haas;0;1;0;1",
                 "Gent;1;0;0;1",
                 "Rank;1;0;0;1" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
      
    end

    it "should count column values based on number comparison" do
      counter = Counter.new(infile: @in_ibase_file, outfile: @out_file, rows: "1-10",
                            cols: "1:<10,1:10-50,1:>50", key: "0:customer", sum: "Total:1,Sumsup")
      counter.execute

      result = [ "customer;10-50;<10;>50;Sumsup",
                 "Total;3;4;2;9",
                 "Fink;0;1;0;1",
                 "Haas;1;0;0;1",
                 "Rank;0;0;1;1",
                 "Klick;1;0;0;1",
                 "Black;0;1;0;1",
                 "White;0;0;1;1",
                 "Tong;0;1;0;1",
                 "Rinda;0;1;0;1",
                 "Pings;1;0;0;1" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
     end

    it "should use multiple key columns" do
      counter = Counter.new(infile: @in_ibase_file, outfile: @out_file, rows: "1-10",
                            cols: "1:<10,1:10-50,1:>50", key: "0:customer,1:machines", 
                            sum: "Total:1,Sumsup")
      counter.execute

      result = [ "customer;machines;10-50;<10;>50;Sumsup",
                 "Total;;3;4;2;9",
                 "Fink;9;0;1;0;1",
                 "Haas;34;1;0;0;1",
                 "Rank;60;0;0;1;1",
                 "Klick;25;1;0;0;1",
                 "Black;2;0;1;0;1",
                 "White;88;0;0;1;1",
                 "Tong;3;0;1;0;1",
                 "Rinda;8;0;1;0;1",
                 "Pings;15;1;0;0;1" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

  end

end
