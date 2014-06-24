require 'sycsvpro/table'

module Sycsvpro

  describe Table do
    before do
      @in_file          = File.join(File.dirname(__FILE__), "files/table.csv")
      @in_file_revenues = File.join(File.dirname(__FILE__), 
                                    "files/table_revenues.csv")
      @out_file         = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should create headings from String and column values" do
      Sycsvpro::Table.new(infile: @in_file,
                          outfile: @out_file,
                          header:  "Year,c6,c1",
                          key:     "c0=~/\\.(\\d{4})/,c6",
                          cols:    "Value:+n1").execute

      result = [ "Year;Country;Value", 
                 "2013;AT;53.7", 
                 "2014;DE;21.0",
                 "2014;AT;20.5" ] 

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

    it "should create headings from operation" do
      Sycsvpro::Table.new(infile: @in_file,
                          outfile: @out_file,
                          header:  "Year,c6,c1,c2+c3",
                          key:     "c0=~/\\.(\\d{4})/,c6",
                          cols:    "Value:+n1,c2+c3:+n1").execute

      result = [ "Year;Country;Value;A1;B2;B4", 
                 "2013;AT;53.7;20.5;0;33.2", 
                 "2014;DE;21.0;0;21.0;0",
                 "2014;AT;20.5;20.5;0;0" ] 

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

    it "should create key from operation" do
      Sycsvpro::Table.new(infile: @in_file,
                          outfile: @out_file,
                          header:  "c4,c5,c0=~/\\.(\\d{4})/",
                          key:     "c4,c5",
                          cols:    "c0=~/\\.(\\d{4})/:+n1").execute

      result = [ "Customer Name;Customer-ID;2013;2014", 
                 "Hank;133;20.5;20.5",
                 "Hans;234;0;21.0",
                 "Jack;432;33.2;0" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

    it "should add a sum row" do
      Sycsvpro::Table.new(infile: @in_file,
                          outfile: @out_file,
                          header:  "Year,c6,c1,c2+c3",
                          key:     "c0=~/\\.(\\d{4})/,c6",
                          cols:    "Value:+n1,c2+c3:+n1",
                          sum:     "top:Value,c2+c3").execute

      result = [ "Year;Country;Value;A1;B2;B4", 
                 ";;95.2;41.0;21.0;33.2",
                 "2013;AT;53.7;20.5;0;33.2", 
                 "2014;DE;21.0;0;21.0;0",
                 "2014;AT;20.5;20.5;0;0" ] 

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

    it "should add a sum row at after the heading" do
      Sycsvpro::Table.new(infile: @in_file,
                          outfile: @out_file,
                          header:  "c4,c5,c0=~/\\.(\\d{4})/",
                          key:     "c4,c5",
                          cols:    "c0=~/\\.(\\d{4})/:+n1",
                          sum:     "TOP:c0=~/\\.(\\d{4})/").execute

      result = [ "Customer Name;Customer-ID;2013;2014", 
                 ";;53.7;41.5",
                 "Hank;133;20.5;20.5",
                 "Hans;234;0;21.0",
                 "Jack;432;33.2;0" ]

      rows = 0

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should add a sum row at the bottom" do
      Sycsvpro::Table.new(infile: @in_file,
                          outfile: @out_file,
                          header:  "c4,c5,c0=~/\\.(\\d{4})/",
                          key:     "c4,c5",
                          cols:    "c0=~/\\.(\\d{4})/:+n1",
                          sum:     "EOF:c0=~/\\.(\\d{4})/").execute

      result = [ "Customer Name;Customer-ID;2013;2014", 
                 "Hank;133;20.5;20.5",
                 "Hans;234;0;21.0",
                 "Jack;432;33.2;0",
                 ";;53.7;41.5" ]

      rows = 0

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should process cols with commas within expression" do

      sp_order_type = %w{ ZE ZEI Z0 }
      rp_order_type = %w{ ZRN ZRK }

      Sycsvpro::Table.new(infile: @in_file_revenues,
                          outfile: @out_file,
                          header:  "Year,SP,RP,Total",
                          key:     "c0=~/\\.(\\d{4})/",
                          cols:    "SP:+n2 if #{sp_order_type}.index(c1),"+
                                   "RP:+n2 if #{rp_order_type}.index(c1),"+
                                   "Total:+n2",
                          nf:      "DE",
                          sum:     "top:SP,RP,Total").execute

      result = [ "Year;SP;RP;Total", 
                 ";345.2;3925.73;4270.93",
                 "2012;300.7;3580.1;3880.8", 
                 "2013;44.5;345.63;390.13" ] 

      rows = 0

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

  end

end
