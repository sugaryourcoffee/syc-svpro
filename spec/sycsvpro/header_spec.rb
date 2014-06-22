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

    it "should create a header from 'A,c1,c2+c3'" do
      header = Header.new("A,c1,c2+c3")

      header.process("a0;a1;a2;a3;a4;a5").should eq "A;a1;a2a3"
      header.process("b0;b1;b2;b3;b4;b5").should eq "A;a1;a2a3;b2b3"
    end

    it "should create a header form 'A,c1,c2+'-'+c3'" do
      header = Header.new("A,c1,c2+'-'+c3")

      header.process("a0;a1;a2;a3;a4;a5").should eq "A;a1;a2-a3"
      header.process("b0;b1;b2;b3;b4;b5").should eq "A;a1;a2-a3;b2-b3"
    end

    it "should create a header from 'c4,A,c0=~/\.(\d{4})/,c1,B'" do
      header = Header.new("c4,A,c0=~/\\.(\\d{4})/,c1,B")

      header.process("a0;a1;a2;a3;a4;a5").should eq "a4;A;a1;B"
      header.process("1.1.2012;b1;b2;b3;b4;b5").should eq "a4;A;2012;a1;B"
      header.process("3.4.2013;c1;c2;c3;c4;c5").should eq "a4;A;2012;2013;a1;B"
    end

  end

end
