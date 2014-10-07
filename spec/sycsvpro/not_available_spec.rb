require 'sycsvpro/not_available'

module Sycsvpro

  describe NotAvailable do

    it "should return na in arithmetic expression like na + 1" do
      na = NotAvailable #NotAvailable.new

      (na + 1).should eq na
      (na * 2).should eq na
      (na / 3).should eq na
      (na - 4).should eq na
    end

    it "should return na in arithmetic expression like 1 + na" do
      na = NotAvailable #NotAvailable.new

      (1 + na).should eq na
      (2 * na).should eq na
      (3 / na).should eq na
      (4 - na).should eq na
    end

    it "should return na in arbitrary arithmetic expression" do
      na = NotAvailable #NotAvailable.new

      (na + 1 + 2 * na).should eq na
      (1 + 2 * 3 + na * 4).should eq na
    end

  end

end
