require 'sycsvpro/calculator.rb'

module Sycsvpro

  describe Calculator do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/machines.csv")
      @in_date_file = File.join(File.dirname(__FILE__), "files/machine-delivery.csv")
      @in_number_file = File.join(File.dirname(__FILE__), "files/machine-count.csv")
      @in_customer_file = File.join(File.dirname(__FILE__), "files/customers.csv")
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

    it "should find maximum of specified date rows" do
      header = "*,Max Date"
      cols   = "3:[d1,d2].compact.max"
      rows   = "1-8"
      df     = "%d.%m.%Y"

      calculator = Calculator.new(infile: @in_date_file, outfile: @out_file, 
                                  header: header, rows: rows, cols: cols, df: df)
      calculator.execute

      result = ["customer;delivery;registration;Max Date",
                "Fink;1.10.2014;30.9.2013;2014-10-01",
                "Haas;3.3.2012;10.10.2013;2013-10-10",
                "Gent;8.5.1995;11.2.1999;1999-02-11",
                "Rank;;1.3.2002;2002-03-01" ]

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
      end
    end

    it "should find minimum of specified date rows" do
      header = "*,Min_Date"
      cols   = "3:[d1,d2].compact.min"
      rows   = "1-8"
      df     = "%d.%m.%Y"

      calculator = Calculator.new(infile: @in_date_file, outfile: @out_file, 
                                  header: header, rows: rows, cols: cols, df: df)
      calculator.execute

      result = ["customer;delivery;registration;Min_Date",
                "Fink;1.10.2014;30.9.2013;2013-09-30",
                "Haas;3.3.2012;10.10.2013;2012-03-03",
                "Gent;8.5.1995;11.2.1999;1995-05-08",
                "Rank;;1.3.2002;2002-03-01" ]

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
      end
    end

    it "should find maximum of specified number rows" do
      header = "*,Max Number"
      cols   = "4:[c1,c2,c3].max"
      rows   = "1-8"
      df     = "%d.%m.%Y"

      calculator = Calculator.new(infile: @in_number_file, outfile: @out_file, 
                                  header: header, rows: rows, cols: cols, df: df)
      calculator.execute

      result = ["customer;before;between;after;Max Number",
                "Fink;2;3;1;3",
                "Haas;3;1;6;6",
                "Gent;4;4;4;4",
                "Rank;5;4;1;5"]

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
      end
    end

    it "should find minimum of specified number rows" do
      header = "*,Min Number"
      cols   = "4:[c1,c2,c3].min"
      rows   = "1-8"
      df     = "%d.%m.%Y"

      calculator = Calculator.new(infile: @in_number_file, outfile: @out_file, 
                                  header: header, rows: rows, cols: cols, df: df)
      calculator.execute

      result = ["customer;before;between;after;Min Number",
                "Fink;2;3;1;1",
                "Haas;3;1;6;1",
                "Gent;4;4;4;4",
                "Rank;5;4;1;1"]

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
      end
    end

    it "should split column value into multiple column values" do
      header = "ID,Customer,Country"
      cols   = [ "2:s0.scan(/([A-Z]+)/).flatten[0]",
                 "0:s0.scan(/(?<=\\/)(.*)$/).flatten[0]",
                 "1:s1" ].join(',')
      rows   = "1-8"

      Calculator.new(infile:  @in_customer_file,
                     outfile: @out_file,
                     header:  header,
                     rows:    rows,
                     cols:    cols).execute

      result = [ "ID;Customer;Country",
                 "123945;Hank;DE",
                 "339339;Frank;AT",
                 "449399;Jane;DE",
                 "33A398;Jean;US" ]

      rows = 0

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

  end

end
