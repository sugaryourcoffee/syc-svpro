module Sycsvpro

  class Profile

    attr_reader :pro_file

    def initialize(pro_file)
      @pro_file = pro_file
    end

    def execute
      load pro_file
    end

  end

end
