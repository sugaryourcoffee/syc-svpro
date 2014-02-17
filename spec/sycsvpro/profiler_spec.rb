require 'sycsvpro/profiler.rb'

module Sycsvpro

  describe Profiler do

    before do
      @profile = File.join(File.dirname(__FILE__), "files/profile.rb")
      @method  = "calc"
      @out_file = File.join(File.dirname(__FILE__), "files/out.csv")
    end

    it "should execute the profile file" do
      profiler = Profiler.new(@profile)

      profiler.execute(@method)

      result = [ "customer;con123;con332;con333;dri111;dri222;dri321",
                 "Fink;1;0;1;0;1;1",
                 "Haas;0;1;0;1;0;0",
                 "Gent;1;0;0;1;0;0",
                 "Rank;0;1;0;0;0;1",
                 "Klig;0;1;0;0;1;0" ]

      File.open(@out_file).each_with_index do |line, index|
        line.chomp.should eq result[index]
      end

    end

  end

end
