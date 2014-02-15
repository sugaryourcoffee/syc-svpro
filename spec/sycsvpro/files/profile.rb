# This is an example of a sycsvpro DSL to process a CSV file

def calc

  customers = {}
  heading = []

  rows infile: "./spec/sycsvpro/files/in.csv", 
       row_filter: "1-20",
       key_column: 0, 
       machine_column: 3, 
       data_columns: [4,5] do |key, machine, columns|
    customer = customers[key] || customers[key] = { name: key, products: Hash.new(0) }
    columns.each do |column|
      heading << column if heading.index(column).nil?
      customer[:products][column] += 1
    end
  end
  
#  puts heading.sort.join('-')

=begin
  customers.each do |k,v|
    print k
    heading.sort.each do |h|
      print " #{v[:products][h]} "
    end
    puts
  end
=end

  write_to "./spec/sycsvpro/files/out.csv" do |out|
    out.puts (["customer"] + heading.sort).join(';')
    customers.each do |k,v|
      line = [k]
      heading.sort.each do |h|
        line << v[:products][h]
      end
      out.puts line.join(';')
    end
  end
end
