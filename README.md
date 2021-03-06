syc-svpro
=========

Processing of csv files. *sycsvpro* offers following functions

* analyze a csv file
* extract rows and columns from a file
* remove duplicate lines from a file where duplicates are identified by key
  columns (since version 0.1.11)
  add unique to command line interface (since version 0.1.12)
* collect values of rows and assign them to categories
* map column values to new values
* allocate column values to a key column (since version 0.0.4)
* count values in columns and use the value as column name
* aggregate row values and add the sum to the end of the row
* arithmetic operations on values of columns
* sort rows based on columns (since version 0.0.9)
* insert rows to a csv-file (since version 0.0.8)
* create or edit a Ruby script
* list scripts available optionally with methods (since version 0.0.7)
* execute a Ruby script file that operates a csv file
* create a table from a source file with dynamically create columns (since 
  version 0.1.4)
* join two file based on a joint column value (since version 0.1.7)
* merge files based on common headline columns (since version 0.1.10)
* transpose (swapping) rows and columns (since version 0.1.13)
* arithmetic operations between multiple files that have a table like
  structure (since version 0.2.0)

To get help type

    $ sycsvpro -h
    
In the following examples we assume the following files 'machines.csv', 
'region.csv' and revenue.csv

```
customer;machine;control;drive;motor;date;contract;price;c-id
hello;h1;con123;dri120;mot100;1.01.3013;1;2.5;123
hello;h2;con123;dri130;mot110;1.02.3012;1;12.1;123
indix;i1;con456;dri130;mot090;5.11.3013;1;23.24;345
chiro;c1;con333;dri110;mot100;1.10.3011;1;122.15;456
chiro;c2;con331;dri100;mot130;3.05.3010;1;25.3;456
```

```
region;country;c-id
R1;DE,123
R2;AT;234
R3;US;345
R4;CA;456
```

```
2010;2011;2012;2013;2014;customer
50;100;150;100;200;hello
100;50;10;1000;20;indix
2000;250;300;3000;chiro
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


Unique
------
Remove duplicate lines from a file. Duplicates are identified by key columns.
If no key columns are provided the whole line is checked for uniqueness

    $ sycsvpro -f in.csv -o out.csv unique -r 1,2,8-12 -c 4,10-15 -k 0,1

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
Map the product names to new names. Consider columns 2-4 only for mapping

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

Transpose
---------
Swap rows and columns of revenue.csv to out.csv

    $ sycsvpro -f revenue.csv -o out.csv transpose
    
    2010;50;100;2000
    2011;100;50;250
    2012;150;10;300
    2013;100;1000;3000
    2014;200;20;20
    customer;hello;indix;chiro

To use only columns 2013 and 2014 you can specify a the columns to transpose

    $ sycsvpro -f revenue.csv -o out.csv transpose -c 3-5

    2013;100;1000;3000
    2014;200;20;20
    customer;hello;indix;chiro

To filter for hello only

    $ sycsvpor -f revenue.csv -o out.csv transpose -c 3-5 -r 0,1

    2013;100
    2014;200
    customer;hello

Allocate
--------
Allocate all the machine types to the customer

    $ sycsvpro -f in.csv -o out.csv assign -k 0 -r 1-20 -c 1

    hello;h1;h2
    indix;i1
    chiro;c1;c2

Count
-----
Count all customers (key column) in rows 2 to 20 that have machines that start 
with *h* and have a contract valid beginning after 1.1.2000. Add a sum row with
title Total at column 1

    $ sycsvpro -f in.csv -o out.csv count -r 2-20 -k 0:customer 
               -c 1:/^h/,5:">1.1.2000" --df "%d.%m.%Y" -s "Total:1"

The result in file out.csv is

    $ cat out.csv
    customer;>1.1.2000;^h
    Total;5;2
    hello;2;2
    indix;1;0
    chiro;2;0

It is possible to use multiple key columns `-k 0:customer,1:machines`

Aggregate
---------
Aggregate row values and add the sum to the end of the row. In the example we 
aggregate the customer names.

    $ sycsvpro -f in.csv -o out.csv aggregate -c 0 -s Total:1,Sum

The aggregation result in out.csv is

    $ cat out.csv
    customer;Sum
    Total;5
    hello;2
    indix;1
    chiro;2

Table
-----
Analyze the contract revenue per customer and per year

    $ sycsvpro -f in.csv -o out.csv table 
               -h "Customer,c5=~/\\.(\\d{4})/"
               -k c1
               -c "c5=~/\\.\\d{4})/:+n1" 

The table result will be in out.csv

    $ cat out.csv
      Customer;3013;3012;3011;3010
      hello;2.5;12.1;0;0
      indix;23.24;0;0;0
      chiro;0;0;122.15;25.3

Calc
----
Process arithmetic operations on the contract count and create a target column 
and a sum which is added at the end of the result file

    $ sycsvpro -f in.csv -o out.csv calc -r 2-20 -h *,target 
               -c 6:*2,7:c6*10

    $ cat out.csv
    customer;machine;control;drive;motor;date;contract;target
    hello;h1;con123;dri120;mot100;1.01.3013;2;20
    hello;h2;con123;dri130;mot110;1.02.3012;2;20
    indix;i1;con456;dri130;mot090;5.11.3013;2;20
    chiro;c1;con333;dri110;mot100;1.10.3011;2;20
    chiro;c2;con331;dri100;mot130;3.05.3010;2;20
    0;0;0;0;0;0;10;100

In the sum row non-numbers in the colums are converted to 0. Therefore column 0
is summed up to 0 as all strings are converted to 0.

Write only columns 0, 6 and 7 by specifying write columns

    $ sycsvpro -f in.csv -o out.csv calc -r 2-20 -h "customer,contract,target"
                                         -c 6:*2,7:c6*10
                                         -w 0,6-7
    $ cat out.csv
    customer;contract;target
    hello;2;20
    hello;2;20
    indix;2;20
    chiro;2;20
    chiro;2;20
    0;10;100

Spread Sheet
------------
A spread sheet is a table with rows and columns. On or between spread sheets
operations can be conducted. A spread sheet's rows must have same column
sizes and may have row and column labels.

Use cases are

* arithmetic operations on spread sheets
* information about table like data

###Example for Arithmetic Operation
Asume we want to calculate the market for computer services. We have the count 
of computers in each country, we are offering different services with service
specific prices. We know the market for each service in percent. With this data 
we can calculate the market value.

Count of computers in target countries

            [Tablet] [Laptop] [Desktop]
    [CA]        1000     2000       500
    [DE]        2000     3000       400
    [MX]         500     4000       800
    [RU]        1500     1500      1000
    [TR]        1000     2500      3000
    [US]        3000     3500      1200

Prices for different services offered computer specific

              [Clean] [Maintain] [Repair]
    [Tablet]       10         50      100
    [Laptop]       20         60      150
    [Desktop]      50        100      200

Market for the different services

              [Clean] [Maintain] [Repair]
    [Tablet]     0.10       0.05     0.03
    [Laptop]     0.05       0.10     0.02
    [Desktop]    0.20       0.30     0.04

To calculate the market value we have to multiply each row of the country file
with the columns of the service prices and service market file (for readabiltiy
it has been split up to multiple rows)

    $ sycsvpro -o market_value.csv spreadsheet \
      -f country.csv,prices.csv,market.csv \
      -a country,price,market \
      -o "SpreadSheet.bind_columns( \
          country.transpose.column_collect { |value| value * price * market } \
        ).transpose"

    Note: If you get obscure errors then check whether your aliases (-a flag)
          conflict with a method of your classes. Therefore it is adviced to
          always use specific names like in the example country, price, market

The result of the operation is written to market\_value.csv (labels have been
optimized for better readability)
                                                      
                  [Tablet] [Laptop] [Desktop]
    [CA-Clean]      1000.0   2000.0    5000.0
    [CA-Maintain]   2500.0  12000.0   15000.0
    [CA-Repair]     3000.0   6000.0    4000.0
    [DE-Clean]      2000.0   3000.0    4000.0
    [DE-Maintain]   5000.0  18000.0   12000.0
    [DE-Repair]     6000.0   9000.0    3200.0
    [MX-Clean]       500.0   4000.0    8000.0
    [MX-Maintain]   1250.0  24000.0   24000.0
    [MX-Repair]     1500.0  12000.0    6400.0
    [RU-Clean]      1500.0   1500.0   10000.0
    [RU-Maintain]   3750.0   9000.0   30000.0
    [RU-Repair]     4500.0   4500.0    8000.0
    [TR-Clean]      1000.0   2500.0   30000.0
    [TR-Maintain]   2500.0  15000.0   90000.0
    [TR-Repair]     3000.0   7500.0   24000.0
    [US-Clean]      3000.0   3500.0   12000.0
    [US-Maintain]   7500.0  21000.0   36000.0
    [US-Repair]     9000.0  10500.0    9600.0

###Example for Information on Spread Sheets
With the analyze command we get information about the general structure and some
sample data of a csv file. If we want to look at the csv file more detailed we 
can use the spreadsheet command. In this case we don't want to write the result
to the file as it is no spread sheet, so we can ommit the global -o option.

    sycsvpro spreadsheet -f country.csv -r true -c true -a a \
                         -o "puts;puts a;puts a.ncol;puts a.nrow;puts a.size"

This will give us the information about the data, the number of columns and rows
and the number of values in the csv file. But for this case there is a standard
method that provides this information

    sycsvpro spreadsheet -f country.csv -r true, -c true -a a -o "a.summary"

    Summary
    -------
    rows: 6, columns: 3, dimension: [6, 3], size: 18

    row labels:
     ["CA","DE","MX","RU","TR","US"]
    column labels:
     ["Clean","Maintain","Repair"]

If the result is no spread sheet it won't be written to the outfile (-o) but we
can print the result to the console with the -p flag

    sycsvpro spreadsheet -f country.csv,prices.csv,market.csv \
                         -r true,true,true -c true,true,true \
                         -a country,price,market \
                         -o "result = []; \
                             a.each_column { \
                               |column| result << column * price * market \
                             }; \
                             result" \
                         -p

The last evaluation, in this case result, will be returned as the result. The
-p flag will print the result to the console

    Operation
    ---------
    result = []
    country.transpose.each_column { |column| result << column * price * market }
    result

    Result
    ------
                              [CA*Clean*Clean] [CA*Maintain*Maintain] [CA*Repair*Repair]
       [Tablet*Tablet*Tablet]           1000.0                 2500.0             3000.0
       [Laptop*Laptop*Laptop]           2000.0                12000.0             6000.0
    [Desktop*Desktop*Desktop]           5000.0                15000.0             4000.0
                              [DE*Clean*Clean] [DE*Maintain*Maintain] [DE*Repair*Repair]
       [Tablet*Tablet*Tablet]           2000.0                 5000.0             6000.0
       [Laptop*Laptop*Laptop]           3000.0                18000.0             9000.0
    [Desktop*Desktop*Desktop]           4000.0                12000.0             3200.0
                              [MX*Clean*Clean] [MX*Maintain*Maintain] [MX*Repair*Repair]
       [Tablet*Tablet*Tablet]            500.0                 1250.0             1500.0
       [Laptop*Laptop*Laptop]           4000.0                24000.0            12000.0
    [Desktop*Desktop*Desktop]           8000.0                24000.0             6400.0
                              [RU*Clean*Clean] [RU*Maintain*Maintain] [RU*Repair*Repair]
       [Tablet*Tablet*Tablet]           1500.0                 3750.0             4500.0
       [Laptop*Laptop*Laptop]           1500.0                 9000.0             4500.0
    [Desktop*Desktop*Desktop]          10000.0                30000.0             8000.0
                              [TR*Clean*Clean] [TR*Maintain*Maintain] [TR*Repair*Repair]
       [Tablet*Tablet*Tablet]           1000.0                 2500.0             3000.0
       [Laptop*Laptop*Laptop]           2500.0                15000.0             7500.0
    [Desktop*Desktop*Desktop]          30000.0                90000.0            24000.0
                              [US*Clean*Clean] [US*Maintain*Maintain] [US*Repair*Repair]
       [Tablet*Tablet*Tablet]           3000.0                 7500.0             9000.0
       [Laptop*Laptop*Laptop]           3500.0                21000.0            10500.0
    [Desktop*Desktop*Desktop]          12000.0                36000.0             9600.0

Join
----
Join the machine and contract file with columns from the customer address file

    $ sycsvpro -f in.csv -o out.csv join address.csv -c 0,1 
                                                     -p 2,1
                                                     -i "COUNTRY,REGION"
                                                     -j "3=8"

This will create the result

```
customer;COUNTRY;REGION;machine;control;drive;motor;date;contract;price;c-id
hello;DE;R1;h1;con123;dri120;mot100;1.01.3013;1;2.5;123
hello;DE;R1;h2;con123;dri130;mot110;1.02.3012;1;12.1;123
indix;US;R3i1;con456;dri130;mot090;5.11.3013;1;23.24;345
chiro;CA;R4;c1;con333;dri110;mot100;1.10.3011;1;122.15;456
chiro;CA;R4;c2;con331;dri100;mot130;3.05.3010;1;25.3;456
```

If you have multiple IDs in a row than you can also conduct multiple joins in
on streak.

    $ sycsvpro -f in.csv -o out.csv join address.csv -c 0,1;0,3 
                                                     -p 2,1;4,5
                                                     -i "COUNTRY,REGION"
                                                     -j "3=8;3=10"

Merge
-----
Merge files machine_count.csv and revenue.csv based on the year columns.

    $ sycsvpro -o out.csv merge machines.csv,revenue.csv 
                                -h "2010,2013,2014"
                                -k "0,5"
                                -s "(\\d{4}),(\\d{4})"

This will create the out.csv

```
$ cat out.csv
;2010;2013;2014
hello;1;0;0
indix;1;0;0
chiro;0;1;0
hello;50;100;200
indix;100;1000;20
chiro;2000;300;3000
```

Sort
----
Sort rows on specified columns as an example sort rows based on customer 
(string s) and contract date (date d)

    $ sycsvpro -f in.csv -o out.csv sort -r 2-20 -c s:0,d:5
    
    $cat out.csv
    customer;machine;control;drive;motor;date;contract;target
    hello;h2;con123;dri130;mot110;1.02.3012;1
    hello;h1;con123;dri120;mot100;1.01.3013;1
    indix;i1;con456;dri130;mot090;5.11.3013;1
    chiro;c2;con331;dri100;mot130;3.05.3010;1
    chiro;c1;con333;dri110;mot100;1.10.3011;1

Sort expects the first non-empty row as the header row. If --headerless switch 
is set then sort assumes no header being available.

Insert
------
Add rows at the bottom or on top of a file. The command below adds the content
of the file file-with-rows-to-insert.text on top of the file in.csv and saves 
it to out.csv

    $ sycsvpro -f in.csv -o out.csv insert file-with-rows-to-insert.txt -p top

Edit
----
Creates or if it exists opens a file for editing. The file is created in the 
directory ~/.syc/sycsvpro/scripts. Following command creates a Ruby script with
the name script.rb and a method call_me

    $ sycsvpro edit -s script.rb -m call_me

List
----
List the scripts, insert-file or all scripts available in the scripts directory
which is also displayed. Comments before methods are also displayed

    script directory: ~/.syc/sycsvpro/scripts
    $ sycsvpro list -m
    script.rb
      call_me

Execute
-------
Execute takes a Ruby script file as an argument and processes the script. The 
following command executes the script *script.rb* and invokes the method *calc*

    $ sycsvpro execute ./script.rb calc

Below is an example script file that is ultimately doing the same as the count 
command

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

*rows* and *write_to* are convenience methods provided by sycsvpro that can be 
used in script files to operate on files.

*rows* will return values at the specified columns in the order they are 
provided in the call to rows. The columns to be returned in the block have to 
end with _column_ or _columns_ dependent if a value or an array should be 
returned. You can find the *rows* and *write_to* methods at 
_lib/sycsvpro/dsl.rb_.

Examples for scripts using sycsvpro can be found at 
[sugaryourcoffee/sycsvpro-scripts](https://github.com/sugaryourcoffee/sycsvpro-scripts)

Working with sycsvpro
=====================

sycsvpro emerged from my daily work when cleaning and anaylzing data. If you 
want to dig deeper I would recommend [R](http://www.r-project.org/).

A work flow could be as follows

* Analyze the file `analyze` or `spreadsheet`
* Clean the data `map`
* Extract rows and columns of interest `extract`
* Count values `count`
* Do arithmetic operations on the values `calc` or `spreadsheet`
* Sort the rows based on column values `sort`

When I have analyzed the data I use _Microsoft Excel_ or _LibreOffice Calc_ to 
create nice graphs. To create more sophisiticated analysis *R* is the right tool 
to use. I also use sycsvpro to clean and prepare data and then do the analysis
with *R*.

Release notes
=============

Version 0.1.2
-------------
* Now it is possible to have comma ',' in the filter as non separating values. 
  You can now define a filter like 1-2,4,/[56789]{2,}/,10
* Filtering rows on boolean expression based on values contained in columns.
  The boolean expression has to be enclosed between BEGIN and END

  Example:
    + ``-r BEGINs0=='Ruby'&&n1<1||d2==Date.new(2014,6,17)END``
    + s0 - string in column 0
    + n1 - number in column 1
    + d2 - date   in column 2
* ``list`` shows the directory of the script file (`dir: true`) and has the 
flag *all* to show all scripts, that is _insert files_ and _Ruby files_
* When counting columns with *count* the column headers are sorted
alphabetically. No it is possible to set ``sort: false`` to keep the column
headers in the sequence they are specified

Version 0.1.3
-------------
* In counter `sort: false` didn't work with column filters like `cols: "1,2"`.
Now all filters work
* Sorter now accepts a start row where to start sorting. Rows before the start
row are added on top of the sorted file
* `sycsvpro -f infile analyze` now lists the columns with sample data
* Add `params` method to *Dsl* that retrieves the params provided in the execute
command: `sycsvpro execute script.rb method infile param1 param2`
* Add `clean\_up` to *Dsl* that takes files to be deleted after the script has
run: `clean\_up(%w{file1 file2})`

Version 0.1.4
-------------
* A new Table class is available with following features
    * Create dynamic headline columns based on source table data
    * Associate values to multi keys
    * Create values based on arithmetic operations of source table data
  Example
      `sycsvpro -f in.csv -o out.csv table -h "c4,c5,c0=~/\\.(\\d{4})/" 
                                           -k "c4,c5" 
                                           -c "c0=~/\\.(\\d{4})/:+n1"`
  + h the header is created from the source table header of column 4 and 5.
      Another header column is created dynamicall based on the year part of 
      a date in column 0
  + k the key is based on source table of column 4 and 5
  + c the column operation is in the form HeaderName:Operation. In this case
      the HeaderName is dynamically determined based on column 0 and added
      the value of column 1 to this column that is associated to the key

  c4, n4, d4 are string, number and date values respectively

Version 0.1.5
-------------
* Add a sum row after the heading or at the end of file like so
      `sycsvpro -f in.csv -o out.csv table -h   "c4,c5,c0=~/\\.(\\d{4})/" 
                                           -k   "c4,c5" 
                                           -c   "c0=~/\\.(\\d{4})/:+n1"
                                           -s   "c0=~/\\.(\\d{4})/"`
  This will sum up the dynamically created column.

Version 0.1.6
-------------
* Commas within columns expression are now ignored while splitting columns of
  table columns
* Table takes a number format now with `--nf DE` which will convert numbers
  from DE locale like 1.000,00 to 1000.00
* Table uses a precision for numbers. Default is 2. Can be assigned with `pr: 2`

Version 0.1.7
-------------
* Calc can now be used not to only do arithmetic operations on columns but also
  string operations. Ultimately any valid Ruby command can be used to process a
  column value
      `sycsvpro -f customer.csv -o customer-number.csv calc 
                            -h "Customer_ID,Customer,Country" 
                            -r "1-eof" 
                            -c "2:s0.scan(/^([A-Z]+)\\//).flatten[0],
                                0:s0.scan(/(?<=\\/)(.*)$/).flatten[0],1:s1"
* Join is a new class that joins to tables based on a joint column value
      `sycsvpro -f infile.csv -o outfile.csv join source.csv -c "2,4"
                                                             -j "1=3"
                                                             -p "1,3"
                                                             -h "*"
                                                             -i "A,B"`
  This will join infile.csv with source.csv based on the join columns (j "1=3").
  From source.csv columns 2 and 4 (-c "2,4") will be inserted at column
  positions 1 and 3 (-p "1,3"). The header will be used from the infile.csv
  (-h "\*") supplemented by the columns A and B (-i "A,B") that will also be
  positioned at column 1 and 3 (-p "1,3").

Version 0.1.8
-------------
* Join now can join multiple key values in 1 streak

Version 0.1.9
-------------
* When creating columns dynamically in count they are in arbitrary sequence. 
  You can now provide a switch `sort: "2"` which will sort the header from 
  column 2 on.

Version 0.1.10
--------------
* It is now possible to merge multiple files based on common headline columns
* Fix ~/.syc/sycsvpro system directory creation when no .syc directory is 
 available

Version 0.1.11
--------------
* Unique removes duplicate lines from the infile. Duplicate lines are identified
  by key columns

Version 0.1.12
--------------
* Add unique to sycsvpro command line interface

Version 0.1.13
--------------
* Optimize Mapper by only considering columns provided for mapping which should
  increase performance
* match\_boolean\_filter? in Filter now also processes strings with single
  quotes inside
* Tranposer tranposes rows and columns that is make columns rows and vice versa
* Calculator can now have colons inside the operation
     sycsvpro -f in.csv -o out.csv -c "122:+[1,3,5].inject(:+)"
  Previously the operation would have been cut after inject(
* A write flag in Calculator specifies which colons to add to the result.
* Calculator introduced a switch 'final\_header' which indicates the header
  provided should not be filtered in regard to a provided 'write' flag but 
  written to the result file as is
* Merger now doesn't require a key column that is files can be merged without
  key columns.

Version 0.2.0
-------------
* SpreadSheet has been introduced. A spread sheet is used to conduct 
  operations like multiplication, division, addition and subtraction between 
  multiple files that have a table like structure. SpreadSheet can also be used 
  to retrieve information about csv files

Version 0.2.1
-------------
* When creating spread sheets from file empty rows are skipped
* To equalize column sizes of rows in spread sheets `equalize: true` flag was
  introduced
* To distinguish between different number locales like _1.234.567,89_, 
  _1,234,567.89_, _1 234 567.89_ and the like a `ds` flag was introduced to
  spread sheet to indicate the number formatting
* Optimize performance when creating spread sheets from files
* Dsl module has got 3 new methods #is\_integer?, #is\_float? and #str2num to
  convert strings that represent numbers to numericals

Version 0.2.2
-------------
* Add the equalize switch to the spread sheet command line
* Optimize performance of SpreadSheet#write
* Introduce _r_ and _c_ arguments to SpreadSheet#write to indicate whether the
  row and column labels should be written to the file. Row and column labels are
  written per default for compatibility reasons
* Catch encoding errors when creating spread sheet from file

Documentation
=============
The class documentation can be found at 
[rubygems](https://rubygems.org/gems/sycsvpro) and the source code at 
[github](https://github.com/sugaryourcoffee/syc-svpro). This might be valuable 
when writing scripts.

Installation
============
[![Gem Version](https://badge.fury.io/rb/sycsvpro.png)](http://badge.fury.io/rb/sycsvpro)
