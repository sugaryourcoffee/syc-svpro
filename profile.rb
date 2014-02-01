# This is an example of a sycsvpro DSL to process a CSV file


def calc

  customers = {}
  heading = []

  rows infile: "test.csv", 
       row_filter: "2-20",
       key_column: 0, 
       machine_column: 1, 
       data_columns: [2,3,4] do |key, machine, columns|
    customer = customers[key] || customers[key] = { name: key, products: Hash.new(0) }
    puts machine
    columns.each do |column|
      heading << column if heading.index(column).nil?
      customer[:products][column] += 1
    end
    puts "customer: #{key} products: #{customers[key][:products]}"
  end
  
  puts heading.sort.join('-')

  customers.each do |k,v|
    print k
    heading.sort.each do |h|
      print " #{v[:products][h]} "
    end
    puts
  end

  write_to "test_out.csv" do |out|
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
