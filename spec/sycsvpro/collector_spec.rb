require 'sycsvpro/collector.rb'

module Sycsvpro

  describe Collector do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/in.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should collect and categorize values" do
      collector = Collector.new(infile: @in_file, outfile: @out_file, 
                                cols: "customer:0+products:4,5", rows: "1-20")
      collector.execute

      result = ['[customer]', 'Fink', 'Gent', 'Haas', 'Klig', 'Rank', 'fink',
                '[products]', 'con123', 'con332', 'con333', 
                              'dri111', 'dri222', 'dri321']
      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end
    end

  end

end
