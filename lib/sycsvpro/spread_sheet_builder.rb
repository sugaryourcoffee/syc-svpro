module Sycsvpro

  # SpreadSheetBuilder is used in the command line interface of sycsvpro to 
  # use SpreadSheet from the command line
  class SpreadSheetBuilder

    # The result of the SpreadSheet operation is written to this file
    attr_reader :outfile
    # The operands, that is the spread sheets that are used in the arithmetic
    # operation
    attr_reader :operands
    # The spread sheet operation where the operands are used
    attr_reader :operation
    # Indicates whether the result should be printed
    attr_reader :print

    # A spread sheet builder is doing arithmetic operations and can be called
    # like this:
    #
    #     SpreadSheetBuilder.new(outfile:   "out.csv",
    #                            files:     "f1.csv,f2.csv",
    #                            rlabels:   "true,false",
    #                            clabels:   "false,true",
    #                            aliases:   "a,b",
    #                            operation: "(a*b).transpose",
    #                            print:     "true").execute
    #
    # outfile:   file where the result of the operation is written to
    # files:     files that hold the spread sheet data
    # rlabels:   indication whether the corresponding file has row labels
    # clabels:   indication whether the corresponding file has column labels
    # aliases:   symbols that correspond to the spread sheet created from the
    #            files. The symbols are used in the operation. The symbols have
    #            to be choosen carefully not to conflict with existing methods
    #            and variables
    # operation: arithmetic operation on spread sheets using the aliases as
    #            place holders for the spread sheets. The last evaluated
    #            operation is returned as result and saved to outfile in case
    #            the result is a spread sheet. In all other cases the result can
    #            be printed with the print flag.
    # print:     print the result
    def initialize(opts = {})
      @print     = opts[:print]
      @operands  = create_operands(opts)
      @outfile   = opts[:outfile]
      @operation = opts[:operation]
    end

    # Returns the spread sheet operands when called in the arithmetic operation
    def method_missing(name, *args, &block)
      super unless operands.keys.index(name.to_s)
      operands[name.to_s]
    end

    # Executes the operation and writes the result to the outfile
    def execute
      result = eval(operation)      
      if outfile
        if result.is_a?(SpreadSheet)
          result.write(outfile)
        else
          puts
          puts "Warning: Result is no spread sheet and not written to file!"
          puts "         To view the result use -p flag" unless print
        end
      end

      if print
        puts
        puts "Operation"
        puts "---------"
        operation.split(';').each { |o| puts o }
        puts
        puts "Result"
        puts "------"
        if result.nil? || result.empty?
          puts result.inspect
        else
          puts result
        end
        puts
      end
    end

    private

      # Creates the spread sheet operands for the arithmetic operation
      def create_operands(opts)
        files   = opts[:files].split(',')
        rlabels = opts[:rlabels].split(',').collect { |l| l.upcase == "TRUE" }
        clabels = opts[:clabels].split(',').collect { |l| l.upcase == "TRUE" }

        operands = {}
        opts[:aliases].split(',').each_with_index do |a,i|
          operands[a] = SpreadSheet.new(file: files[i], 
                                        r: rlabels[i], c: clabels[i])
        end

        operands
      end
  end

end
