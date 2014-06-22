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
        STDERR.puts "res = #{line.chomp}"
        line.chomp.should eq result[index]
      end
    end

    it "should create headings from operation"

    it "should create key from operation"

    it "should assign values to columns from operation"

 
  end

end
