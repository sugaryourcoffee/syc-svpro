require 'sycsvpro/calculator.rb'

module Sycsvpro

  describe Calculator do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/machines.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/machines_out.csv")
    end

    it "should operate on existing row" do
      rows = "2-8"
      cols = "3:*3,4:*4+1"
      calculator = Calculator.new(infile: @in_file, outfile: @out_file, rows: rows, cols: cols)
      calculator.execute

      result = ["Fink;2;2;3;5", "Haas;3;3;3;5.0", "Gent;4;4;3;5", "Rank;5;5;3;5"]

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
      end 
    end

    it "should add additional rows" do
      header = "*,drives,motors"
      rows = "1-8"
      cols = "5:c3+c4,6:c3*2"
      calculator = Calculator.new(infile: @in_file, outfile: @out_file, 
                                  header: header, rows: rows, cols: cols)
      calculator.execute

      result = ["customer;machines;controls;contracts;visits;drives;motors",
                "Fink;2;2;1;1;2;2",
                "Haas;3;3;1;1.0;2.0;2",
                "Gent;4;4;1;1;2;2",
                "Rank;5;5;1;1;2;2"]

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
      end
    end

    it "should sum specified rows" do
      header = "*,drives,motors"
      rows = "1-8"
      cols = "5:c3+c4,6:c3*2"
      sums = "1,3-5"
      calculator = Calculator.new(infile: @in_file, outfile: @out_file, 
                                  header: header, rows: rows, cols: cols, sum: true)
      calculator.execute

      result = ["customer;machines;controls;contracts;visits;drives;motors",
                "Fink;2;2;1;1;2;2",
                "Haas;3;3;1;1.0;2.0;2",
                "Gent;4;4;1;1;2;2",
                "Rank;5;5;1;1;2;2",
                "0;14;14;4;4.0;8;8"]

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
      end
    end

  end

end
