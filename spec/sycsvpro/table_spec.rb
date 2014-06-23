require 'sycsvpro/table'

module Sycsvpro

  describe Table do
    before do
      @in_file = File.join(File.dirname(__FILE__), "files/table.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
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

  end

end
