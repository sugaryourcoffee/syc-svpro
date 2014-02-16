syc-svpro
=========

Processing of csv files. *sycsvpro* offers following functions

* analyze csv file
* extract rows and columns from a file
* collect values of rows and assign them to categories
* map column values to new values
* count values in columns and use the value as column name
* arithmetic operations on values of columns
* execute a ruby script file that operates a csv file

In the following examples we assume the following file

```
customer;machine;control;drive;motor;date;contract
hello;h1;con123;dri120;mot100;1.12.3013;1
hello;h2;con123;dri130;mot110;1.12.3013;1
indix;i1;con456;dri130;mot090;1.12.3013;1
chiro;c1;con333;dri110;mot100;1.12.3013;1
chiro;c2;con331;dri100;mot130;1.12.3013;1
```

Analyze
-------

Analyze the content of the provided file *in.csv*

    $ sycsvpro -f in.csv analyze
    Analysis of in.csv
    7 columns: ["customer", "machine", "control", "drive", "motor", "date", "contract"]
    10393 rows
    0: customer
    1: machine
    2: control
    3: drive
    4: motor
    5: date
    6: contract
    Row sample data:
    hello;h1;con123;dri120;mot100;16.02.2014;1

Extract
-------

Extract row 1,2 and 10-20 as well as columns 4 and 6-7

    $ sycsvpro -f in.csv -o out.csv extract -r 1,2,10-20 -c 4,6-7

Collect
-------

Collect all product rows (2, 3 and 4) to the category product

    $ sycsvpro -f in.csv -o out.csv collect -r 2-20 -c products:2-4
    $ cat out.csv
    [products]
    con123
    con331
    con333
    con456
    dri100
    dri110
    dri120
    dri130
    mot090
    mot100
    mot110
    mot130

Map
---

Map the product names to new names

The mapping file (mapping) uses the result from the collect command above

con123:control123
con331:control331
con333:control333
con456:control456
dri100:drive100
dri110:drive110
dri120:drive120
dri130:drive130
mot090:motor090
mot100:motor100
mot110:motor110
mot130:motor130

    $ sycsvpro -f in.csv -o out.csv map mapping -c 2-4

Count
-----

Count all customers (key column) in rows 2 to 20 that have machines that start with *h* and have contract valid beginning after 1.1.2000

    $ sycsvpro -f in.csv -o out.csv count -r 2-20 -k 0 -c 1:/^h/,5:">1.1.2000" --df "%d.%m.%Y"

The result in file out.csv is

    $ cat out.csv
    customer;>1.1.2000;^h
    hello;2;2
    indix;1;0
    chiro;2;0

Calc
----

Process arithmetic operations on the contract count and create a target column

    $ sycsvpro -f in.csv -o out.csv calc -r 2-20 -h *,target -c 6:*2,7:target=c6*10

    $ cat out.csv
    customer;machine;control;drive;motor;date;contract;target
    hello;h1;con123;dri120;mot100;1.12.3013;2;20
    hello;h2;con123;dri130;mot110;1.12.3013;2;20
    indix;i1;con456;dri130;mot090;1.12.3013;2;20
    chiro;c1;con333;dri110;mot100;1.12.3013;2;20
    chiro;c2;con331;dri100;mot130;1.12.3013;2;20

Execute
-------

Execute takes a Ruby script file as an argument and processes the script. The following command executes the script *script.rb* and invokes the method *calc*

    $ sycsvpro execute ./script.rb calc

Below is an example script file that is ultimately doing the same as the count command

    $ sycsvpro -f in.csv -o out.csv count -r 1-20 -k 0 -c 4,5

```
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
```

*rows* and *write_to* are convenience methods provided by sycsvpro that can be used in script files to operate on files.

*rows* will return values at the specified columns in the order they are provided in the call to
rows. The columns to be returned in the block have to end with _column_ or _columns_ dependent if a value or an array should be returned. You can find the *rows* and *write_to* methods at _lib/sycsvpro/dsl.rb_.

Working with sycsvpro
=====================

sycsvpro emerged from my daily work when cleaning and anaylzing data. If you want to dig deeper I would recommend [R](http://www.r-project.org/).
