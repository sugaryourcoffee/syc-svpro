# Operating csv files
module Sycsvpro

  # Lists the contents of the script directory. Optionally listing a specific script file and also
  # optionally the methods and associated description of the methods
  class ScriptList

    # Directory that holds the scripts
    attr_reader :script_dir
    # Script file of interest
    attr_reader :script_file
    # Switch indicating whether to show methods
    attr_reader :show_methods
    # Hash holding the list of scripts
    attr_reader :list

    # Creates a new ScriptList. Takes params script_dir, script_file and show_methods
    def initialize(options={})
      @script_dir   = options[:dir]
      @script_type  = options[:type] || 'script'
      @script_type.downcase!
      @script_file  = options[:script] || '*.rb'  if @script_type == 'script'
      @script_file  = options[:script] || '*.ins' if @script_type == 'insert'
      @show_methods = options[:show_methods] if @script_type == 'script'
      @show_methods = false if @script_type == 'insert'
      @list         = {}
    end

    # Retrieves the information about scripts and methods from the script directory
    def execute
      scripts = Dir.glob(File.join(@script_dir, @script_file))
      scripts.each do |script|
        list[script] = []
        if show_methods
          list[script] = retrieve_methods(script)
        end
      end
      list
    end

    private

      # Retrieve the methods including comments if available
      def retrieve_methods(script)
        code = File.read(script)
        methods = code.scan(/((#.*\s)*def.*\s|def.*\s)/)
        result = []
        methods.each do |method|
          result << method[0]
        end
        result
      end
  end

end
