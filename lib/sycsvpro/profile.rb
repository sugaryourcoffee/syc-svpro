require_relative 'dsl'

module Sycsvpro

  class Profile

    include Dsl

    attr_reader :pro_file

    def initialize(pro_file)
      require pro_file
    end

    def execute
      puts self
      calc
    end


  end

end
