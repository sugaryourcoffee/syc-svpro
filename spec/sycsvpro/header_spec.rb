require 'sycsvpro/header'

module Sycsvpro

  describe Header do

    it "should create a header from '*,A,B'" do
      header = Header.new("*,A,B")

      header.process("a;b;c").should eq 'a;b;c;A;B'
    end

    it "should create a header form 'A,c6,c1'" do
      header = Header.new("A,c6,c1")

      header.process("a0;a1;a2;a3;a4;a5;a6").should eq "A;a6;a1"
      header.process("x0;x1;x2;x3;x4;x5;x6").should eq "A;a6;a1"
    end

    it "should not create columns on arithmetic operation" do
      header = Header.new("A,c1,c2+c3")

      header.process("h0;h1;h2;h3;h4;h5", false).should eq "A;h1"
      header.process("a0;a1;a2;a3;a4;a5").should eq "A;h1;a2a3"
      header.process("b0;b1;b2;b3;b4;b5").should eq "A;h1;a2a3;b2b3"
      header.process("c0;a1;a2;c3;a4;a5").should eq "A;h1;a2a3;b2b3;a2c3"

    end

    it "should create a header from 'A,c1,c2+c3'" do
      header = Header.new("A,c1,c2+c3")

      header.process("a0;a1;a2;a3;a4;a5").should eq "A;a1;a2a3"
      header.process("b0;b1;b2;b3;b4;b5").should eq "A;a1;a2a3;b2b3"
      header.process("c0;a1;a2;c3;a4;a5").should eq "A;a1;a2a3;b2b3;a2c3"
    end

    it "should create a header form 'A,c1,c2+'-'+c3'" do
      header = Header.new("A,c1,c2+'-'+c3")

      header.process("a0;a1;a2;a3;a4;a5").should eq "A;a1;a2-a3"
      header.process("b0;b1;b2;b3;b4;b5").should eq "A;a1;a2-a3;b2-b3"
      header.process("c0;a1;a2;a3;c4;c5").should eq "A;a1;a2-a3;b2-b3"
    end

    it "should create a header from 'c4,A,c0=~/\.(\d{4})/,c1,B'" do
      header = Header.new("c4,A,c0=~/\\.(\\d{4})/,c1,B")

      header.process("a0;a1;a2;a3;a4;a5").should eq "a4;A;a1;B"
      header.process("1.1.2012;b1;b2;b3;b4;b5").should eq "a4;A;2012;a1;B"
      header.process("3.4.2013;c1;c2;c3;c4;c5").should eq "a4;A;2012;2013;a1;B"
      header.process("5.5.2012;d1;d2;d3;d4;d5").should eq "a4;A;2012;2013;a1;B"
    end

    it "should create a header with positioned columns" do
      header = Header.new("*", insert: "C,D", pos: [3,7])

      header.process("A;B;E;F;G").should eq "A;B;E;C;F;G;;D"
    end

    it "should return the header" do
      header = Header.new("c4,A,c0=~/\\.(\\d{4})/,c1,B")

      header.process("a0;a1;a2;a3;a4;a5").should eq "a4;A;a1;B"
      header.process("1.1.2012;b1;b2;b3;b4;b5").should eq "a4;A;2012;a1;B"
      header.process("3.4.2013;c1;c2;c3;c4;c5").should eq "a4;A;2012;2013;a1;B"
      header.process("5.5.2012;d1;d2;d3;d4;d5").should eq "a4;A;2012;2013;a1;B"

      header.to_s.should eq "a4;A;2012;2013;a1;B"
    end

    it "should return the index of the coloum" do
      header = Header.new("c4,A,c0=~/\\.(\\d{4})/,c1,B")

      header.process("a0;a1;a2;a3;a4;a5").should eq "a4;A;a1;B"
      header.column_of("a1").should eq 2
      header.process("1.1.2012;b1;b2;b3;b4;b5").should eq "a4;A;2012;a1;B"
      header.column_of("a1").should eq 3
      header.process("3.4.2013;c1;c2;c3;c4;c5").should eq "a4;A;2012;2013;a1;B"
      header.column_of("B").should eq 5
    end

  end

end
