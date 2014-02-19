require 'sycsvpro/allocator'

module Sycsvpro

  describe Allocator do
    
    before do
      @in_file  = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should allocate one value to a key" do
      key  = "1"
      rows = "1-10"
      cols = "0"
      allocator = Allocator.new(infile: @in_file, outfile: @out_file, 
                                key: key, rows: rows, cols: cols)

      allocator.execute

      result = [ "1234;Fink;fink",
                 "3322;Haas",
                 "4323;Gent",
                 "3232;Rank",
                 "4432;Klig" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

    it "should allocate multiple values to a key" do
      key = "0"
      rows = "1-10"
      cols = "4-5"
      allocator = Allocator.new(infile: @in_file, outfile: @out_file,
                               key: key, rows: rows, cols: cols)

      allocator.execute

      result = [ "Fink;con123;con333;dri222;dri321",
                 "Haas;con332;dri111",
                 "Gent;con123;dri111",
                 "Rank;con332;dri321",
                 "Klig;con332;dri222",
                 "fink;con332;dri321" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

  end

end
