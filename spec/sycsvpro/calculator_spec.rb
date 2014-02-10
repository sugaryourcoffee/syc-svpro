require 'sycsvpro/calculator.rb'

module Sycsvpro

  describe Calculator do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/machines.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/machines_out.csv")
    end

    it "should calculate on " do
      rows = "2-4"
      cols = "3:*3,4:*4+1"
      calculator = Calculator.new(infile: @in_file, outfile: @out_file, rows: rows, cols: cols)
      calculator.execute
      File.new(@out_file, 'r').each_with_index do |line, index|
        puts line
      end 
    end
  end

end
