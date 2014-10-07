module Sycsvpro

  # The NotAvailable class is an Eigenclass and used to represent a missing 
  # value. It will return if used in any expression always not available.
  #
  #    na = NotAvailable
  #
  #    na + 1 -> na
  #    1 + na -> na
  class NotAvailable

    class << self

      # Catches all expressions where na is the first argument
      def method_missing(name, *args, &block)
        super if name == :to_ary
        self
      end

      # Catches all expressions where na is not the first argument and swaps
      # value and na, so na is first argument
      def coerce(value)
        [self,value]
      end

      # Returns NA as the string representation
      def to_s
        "NA"
      end
      
    end
  end

end
