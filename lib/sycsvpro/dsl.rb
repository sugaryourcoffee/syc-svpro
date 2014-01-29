module Sycsvpro

  def infile(file)
    puts file
  end

  def outfile(file)
    puts file
  end

  def rows(options={})
    key_column = options[:key_column]
    data_columns = options[:data_columns]
    yield
  end
end
