require 'sycsvpro/script_list'

module Sycsvpro

  describe ScriptList do

    before do
      @dir    = File.join(File.dirname(__FILE__), "files")
      @file_1 = File.join(File.dirname(__FILE__), "files/profile.rb")
      @file_2 = File.join(File.dirname(__FILE__), "files/script.rb")
    end

    it "should list scripts" do
      script_list = ScriptList.new(dir: @dir)

      result = { @file_1 => [], @file_2 => [] }

      script_list.execute.should eq result
    end

    it "should list specified script" do
      script_list = ScriptList.new(dir: @dir, script: "profile.rb")

      result = { @file_1 => [] }

      script_list.execute.should eq result
    end

    it "should list specified script with methods" do
      script_list = ScriptList.new(dir: @dir, script: "script.rb", show_methods: true)

      result = { 
                 @file_2 => ["# Reading and writing\n# a file\ndef read_write\n",
                             "def message\n",
                             "# Say hello\ndef say_hello\n"] 
               }

      script_list.execute.should eq result
      
    end

    it "should list all scripts with methods" do
      script_list = ScriptList.new(dir: @dir, show_methods: true)

      result = {
                 @file_1 => ["def calc\n"],
                 @file_2 => ["# Reading and writing\n# a file\ndef read_write\n",
                             "def message\n",
                             "# Say hello\ndef say_hello\n"]
               }

      script_list.execute.should eq result
    end

  end

end
