# Operating csv files
module Sycsvpro

  # The NotAvailable class is an Eigenclass and used to represent a missing 
  # value. It will return if used in any expression always not available.
  #
  #    na = NotAvailable
  #
  #    na + 1 -> na
  #    1 + na -> na
  class NotAvailable

    # The string representation of NotAvailable
    NA = "NA"

    class << self

      # Catches all expressions where na is the first argument
      def method_missing(name, *args, &block)
        self
      end

      # Catches all expressions where na is not the first argument and swaps
      # value and na, so na is first argument
      def coerce(value)
        [self,value]
      end

      # Checks whether SpreadSheet responds to 'name'. The methods :to_ary and
      # :to_str are excluded
      def respond_to?(name)
        return false if name == :to_ary
        return false if name == :to_str
        super
      end

      # Returns NA as the string representation
      def to_s
        NA
      end
      
    end
  end

end
