module Dsl

  def infile(file)
    @in_file = File.expand_path(file)
    puts file
  end

  def outfile(file)
    @out_file = File.expand_path(file)
    puts file
  end

  def rows(options={})
    puts @out_file
    puts @in_file
    key = Hash.new(0)
    File.foreach(@in_file) do |line|
      next if line.chomp.empty?
      values = line.split(';') 
      key_column = options[:key_column]
      data_columns = options[:data_columns]
       
      yield values[key_column], values.values_at(*data_columns)
    end
  end

end
