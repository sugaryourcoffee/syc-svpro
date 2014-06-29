require 'sycsvpro/table'

module Sycsvpro

  describe Table do
    before do
      @in_file          = File.join(File.dirname(__FILE__), "files/table.csv")
      @in_file_revenues = File.join(File.dirname(__FILE__), 
                                    "files/table_revenues.csv")
      @in_file_orders   = File.join(File.dirname(__FILE__), 
                                    "files/customer_orders.csv")
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

    it "should add a sum row after the heading" do
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
                          cols:    "BEGINSP:+n2 if #{sp_order_type}.index(c1)END,"+
                                   "BEGINRP:+n2 if #{rp_order_type}.index(c1)END,"+
                                   "Total:+n2",
                          nf:      "DE",
                          pr:      "2",
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

    it "should ignore commas within header expressions" do
      Sycsvpro::Table.new(
                       infile:  @in_file_revenues,
                       outfile: @out_file,
                       header:  "Year,BEGINc1=~/^([A-Z]{1,2})/END,Total",
                       key:     "c0=~/\\.(\\d{4})/",
                       cols:    "BEGINc1=~/^([A-Z]{1,2})/:+n2END,Total:+n2",
                       nf:      "DE",
                       pr:      2,
                       sum:     "top:BEGINc1=~/^([A-Z]{1,2})/END,Total").execute

      result = [ "Year;ZE;ZR;Total",
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

    it "should ignore commas within key expressions" do
      Sycsvpro::Table.new(
                       infile:  @in_file_revenues,
                       outfile: @out_file,
                       header:  "Year,BEGINc1=~/^([A-Z]{1,2})/END,Total",
                       key:     "BEGINc0=~/\\d+\\.\\d+\\.(\\d{2,3})/END",
                       cols:    "BEGINc1=~/^([A-Z]{1,2})/:+n2END,Total:+n2",
                       nf:      "DE",
                       sum:     "top:BEGINc1=~/^([A-Z]{1,2})/END,Total").execute

      result = [ "Year;ZE;ZR;Total",
                 ";345.2;3925.73;4270.93",
                 "201;345.2;3925.73;4270.93" ]

      rows = 0

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size

    end

    it "should add a count column for the occurance of column values" do
      Sycsvpro::Table.new(infile: @in_file,
                          outfile: @out_file,
                          header:  "Year,c6,c1,c2+c3,c2+c3+'-Count'",
                          key:     "c0=~/\\.(\\d{4})/,c6",
                          cols:    "Value:+n1,c2+c3:+n1,c2+c3+'-Count':+1",
                          sum:     "top:Value,c2+c3").execute

      result = [ "Year;Country;Value;A1;B2;B4;B4-Count;B2-Count;A1-Count", 
                 ";;95.2;41.0;21.0;33.2;;;",
                 "2013;AT;53.7;20.5;0;33.2;1;0;1", 
                 "2014;DE;21.0;0;21.0;0;0;1;0",
                 "2014;AT;20.5;20.5;0;0;0;0;1" ] 

      rows = 0

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

    it "should create columns from regex scan and string interpolation" do
      rp_order_type = %w{ ZRN ZRK }
      sp_order_type = %w{ ZE ZEI ZO ZOI ZG ZGNT ZRE ZGUP }
      order_type = sp_order_type + rp_order_type

      header = "c3,c4,"+
               "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-SP-R'END,"+
               "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-RP-R'END,"+
               "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-R'END,"+
               "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-SP-O'END,"+
               "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-RP-O'END,"+
               "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-O'END"

      cols = "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-SP-R':+n2 if #{sp_order_type}.index(c1)END,"+
             "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-RP-R':+n2 if #{rp_order_type}.index(c1)END,"+
             "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-R':+n2 if #{order_type}.index(c1)END,"+
             "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-SP-O':+1 if #{sp_order_type}.index(c1)END,"+
             "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-RP-O':+1 if #{rp_order_type}.index(c1)END,"+
             "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-O':+1 if #{order_type}.index(c1)END"

      sum = "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-SP-R'END,"+
            "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-RP-R'END,"+
            "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-R'END,"+
            "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-SP-O'END,"+
            "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-RP-O'END,"+
            "BEGIN(c0.scan(/\\d+\\.\\d+\\.(\\d{4})/).flatten[0]||'')+"+
                  "'-O'END"

      Sycsvpro::Table.new(infile:  @in_file_orders,
                          outfile: @out_file,
                          header:  header,
                          key:     "c3,c4",
                          cols:    cols,
                          nf:      "DE",
                          sum:     "top:#{sum}",
                          sort:    "2").execute

      result = [ "Customer;Customer-ID;2010-O;2010-R;"+
                                      "2010-RP-O;2010-RP-R;"+
                                      "2010-SP-O;2010-SP-R;"+
                                      "2011-O;2011-R;"+
                                      "2011-RP-O;2011-RP-R;"+
                                      "2011-SP-O;2011-SP-R;"+
                                      "2012-O;2012-R;"+
                                      "2012-RP-O;2012-RP-R;"+
                                      "2012-SP-O;2012-SP-R;"+
                                      "2013-O;2013-R;"+
                                      "2013-RP-O;2013-RP-R;"+
                                      "2013-SP-O;2013-SP-R;"+
                                      "2014-O;2014-R;"+
                                      "2014-RP-O;2014-RP-R;"+
                                      "2014-SP-O;2014-SP-R",
                 ";;1;50.0;;;1;50.0;2;300.5;;;2;300.5;1;300.0;1;300.0;;;1;"+
                   "400.0;1;400.0;;;1;150.0;;;1;150.0",
                 "Hank;123;0;0;0;0;0;0;1;100.0;0;0;1;100.0;1;300.0;1;300.0;"+
                          "0;0;0;0;0;0;0;0;0;0;0;0;0;0",
                 "Mia;234;0;0;0;0;0;0;1;200.5;0;0;1;200.5;0;0;0;0;0;0;1;400.0;"+
                          "1;400.0;0;0;1;150.0;0;0;1;150.0",
                 "Ria;333;1;50.0;0;0;1;50.0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;"+
                          "0;0;0;0;0;0;0;0" ]

      rows = 0

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
        rows += 1
      end

      rows.should eq result.size
    end

  end

end
