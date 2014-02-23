# Operating csv files
module Sycsvpro

  # Creates a ruby script scaffold
  class ScriptCreator

    # Directory of the script files
    attr_reader :dir
    # Script name
    attr_reader :script_name
    # Method name
    attr_reader :method_name
    # script_file path
    attr_reader :script_file
    # type of the script-file
    attr_reader :script_type

    # Creates a new ScriptCreator
    def initialize(options={})
      @dir         = File.join(options[:dir], 'scripts')
      @script_name = options[:script]
      @script_type = File.extname(@script_name)
      @method_name = options[:method] if @script_type == '.rb'
      create_script
    end

    private

      # Creates a script file if it doesn't exist and adds an empty method with the provided
      # method name. When file exists and method name is provided the method is appended to the
      # existing file. Note: it is not checked whether method name already exists.
      def create_script
        Dir.mkdir dir unless File.exists? dir
        @script_file = File.join(dir, script_name)
        unless File.exists? @script_file
          File.open(@script_file, 'w') do |f|
            if script_type == '.rb'
              f.print "def "
              f.puts  "#{method_name}" if method_name
              f.puts  "end"
            end
          end
        else
          if method_name and script_type == '.rb'
            File.open(@script_file, 'a') do |f|
              f.puts
              f.puts "def #{method_name}"
              f.puts "end"
            end
          end
        end
      end

  end

end
