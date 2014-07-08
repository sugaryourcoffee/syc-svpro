require 'sycsvpro/unique'

module Sycsvpro

  describe Unique do

    before do
      @infile  = File.join(File.dirname(__FILE__), "files/customer-address.csv")
      @outfile = File.join(File.dirname(__FILE__), "files/out.csv")
    end
    
    it "should remove copies" do

      rows = "0-10"
      cols = "0,1-3"
      key  = "0,1"

      Sycsvpro::Unique.new(infile:  @infile,
                           outfile: @outfile,
                           rows:    rows,
                           cols:    cols,
                           keys:    key).execute

      result = [ "Name;Street;Town;Country",
                 "Jane;Canal;Vancouver;CA",
                 "John;Milton;Washington;US",
                 "Jne;Canal;Vancouver;CA",
                 "Jhn;Milton;Washington DC;US" ]

      rows = 0

      File.open(@outfile).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.count
    end

  end

end
