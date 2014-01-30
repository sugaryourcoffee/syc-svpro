# This is an example of a sycsvpro DSL to process a CSV file


puts self

def calc
  puts self

  infile "test.csv"
  outfile "test_out.csv"

  rows key_column: 0, data_columns: [1,2,3] do |key, columns|
    columns.each do |column|
      #key[column] += 1
      puts "key=#{key} : #{column}"
    end
  end
end
