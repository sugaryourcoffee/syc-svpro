require_relative 'dsl'

# Operating csv files
module Sycsvpro

  # A profiler takes a Ruby script and executes the provided method in the script
  class Profiler

    include Dsl

    # Ruby script file
    attr_reader :pro_file

    # Creates a new profiler
    def initialize(pro_file)
      require pro_file
    end

    # Executes the provided method in the Ruby script
    def execute(method)
      send(method)
    end

  end

end
