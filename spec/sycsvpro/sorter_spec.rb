require 'sycsvpro/sorter'

module Sycsvpro

  describe Sorter do

    before do
      @in_file  = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should sort by one column" do
      rows = "1-30"
      cols = "s:0"
      df   = "%d.%m.%Y"

      sorter = Sorter.new(infile: @in_file, outfile: @out_file, rows: rows, cols: cols, df: df)

      sorter.execute

      result = [  "Fink;1234;20.12.2015;f1;con123;dri222",
                  "Fink;1234;30.12.2016;f2;con333;dri321",
                  "Gent;4323;1.3.2014;g1;con123;dri111",
                  "Haas;3322;1.10.2011;h1;con332;dri111",
                  "Klig;4432;;k1;con332;dri222",
                  "Rank;3232;1.5.2013;r1;con332;dri321",
                  "fink;1234;;f3;con332;dri321" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

    it "should sort by two columns" do
      rows = "1-30"
      cols = "n:1,s:0"
      df   = "%d.%m.%Y"

      sorter = Sorter.new(infile: @in_file, outfile: @out_file, rows: rows, cols: cols, df: df)

      sorter.execute

      result = [  "Fink;1234;20.12.2015;f1;con123;dri222",
                  "Fink;1234;30.12.2016;f2;con333;dri321",
                  "fink;1234;;f3;con332;dri321",
                  "Rank;3232;1.5.2013;r1;con332;dri321",
                  "Haas;3322;1.10.2011;h1;con332;dri111",
                  "Gent;4323;1.3.2014;g1;con123;dri111",
                  "Klig;4432;;k1;con332;dri222" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

    it "should sort by column range" do
      rows = "1-30"
      cols = "s:3-5,s:0"
      df   = "%d.%m.%Y"

      sorter = Sorter.new(infile: @in_file, outfile: @out_file, rows: rows, cols: cols, df: df)

      sorter.execute

      result = [  "Fink;1234;20.12.2015;f1;con123;dri222",
                  "Fink;1234;30.12.2016;f2;con333;dri321",
                  "fink;1234;;f3;con332;dri321",
                  "Gent;4323;1.3.2014;g1;con123;dri111",
                  "Haas;3322;1.10.2011;h1;con332;dri111",
                  "Klig;4432;;k1;con332;dri222",
                  "Rank;3232;1.5.2013;r1;con332;dri321" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end


    it "should sort a date column" do
      rows = "1-30"
      cols = "d:2,s:0"
      df   = "%d.%m.%Y"

      sorter = Sorter.new(infile: @in_file, outfile: @out_file, rows: rows, cols: cols, df: df)

      sorter.execute

      result = [ "Haas;3322;1.10.2011;h1;con332;dri111",
                 "Rank;3232;1.5.2013;r1;con332;dri321",
                 "Gent;4323;1.3.2014;g1;con123;dri111",
                 "Fink;1234;20.12.2015;f1;con123;dri222",
                 "Fink;1234;30.12.2016;f2;con333;dri321",
                 "Klig;4432;;k1;con332;dri222",
                 "fink;1234;;f3;con332;dri321" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end
    
    it "should sort descending" do
      rows = "1-30"
      cols = "d:2,s:0"
      df   = "%d.%m.%Y"

      sorter = Sorter.new(infile: @in_file, outfile: @out_file, rows: rows, cols: cols, df: df,
                          desc: true)

      sorter.execute

      result = [ "fink;1234;;f3;con332;dri321",
                 "Klig;4432;;k1;con332;dri222",
                 "Fink;1234;30.12.2016;f2;con333;dri321",
                 "Fink;1234;20.12.2015;f1;con123;dri222",
                 "Gent;4323;1.3.2014;g1;con123;dri111",
                 "Rank;3232;1.5.2013;r1;con332;dri321",
                 "Haas;3322;1.10.2011;h1;con332;dri111" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

  end

end
