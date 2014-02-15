require_relative 'dsl'

module Sycsvpro

  class Profiler

    include Dsl

    attr_reader :pro_file

    def initialize(pro_file)
      require pro_file
    end

    def execute(method)
      send(method)
    end


  end

end
