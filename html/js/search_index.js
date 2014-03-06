var search_data = {"index":{"searchIndex":["dsl","object","sycsvpro","aggregator","allocator","analyzer","calculator","collector","columnfilter","columntypefilter","counter","extractor","filter","header","inserter","mapper","profiler","rowfilter","scriptcreator","scriptlist","sorter","execute()","execute()","execute()","execute()","execute()","execute()","execute()","execute()","execute()","execute()","execute()","has_filter?()","method_missing()","method_missing()","new()","new()","new()","new()","new()","new()","new()","new()","new()","new()","new()","new()","new()","new()","new()","pivot_each_column()","process()","process()","process()","process()","process()","process_aggregation()","process_count()","result()","rows()","set_max_row()","str2utf8()","unstring()","write_result()","write_result()","write_to()","readme"],"longSearchIndex":["dsl","object","sycsvpro","sycsvpro::aggregator","sycsvpro::allocator","sycsvpro::analyzer","sycsvpro::calculator","sycsvpro::collector","sycsvpro::columnfilter","sycsvpro::columntypefilter","sycsvpro::counter","sycsvpro::extractor","sycsvpro::filter","sycsvpro::header","sycsvpro::inserter","sycsvpro::mapper","sycsvpro::profiler","sycsvpro::rowfilter","sycsvpro::scriptcreator","sycsvpro::scriptlist","sycsvpro::sorter","sycsvpro::aggregator#execute()","sycsvpro::allocator#execute()","sycsvpro::calculator#execute()","sycsvpro::collector#execute()","sycsvpro::counter#execute()","sycsvpro::extractor#execute()","sycsvpro::inserter#execute()","sycsvpro::mapper#execute()","sycsvpro::profiler#execute()","sycsvpro::scriptlist#execute()","sycsvpro::sorter#execute()","sycsvpro::filter#has_filter?()","sycsvpro::calculator#method_missing()","sycsvpro::filter#method_missing()","sycsvpro::aggregator::new()","sycsvpro::allocator::new()","sycsvpro::analyzer::new()","sycsvpro::calculator::new()","sycsvpro::collector::new()","sycsvpro::counter::new()","sycsvpro::extractor::new()","sycsvpro::filter::new()","sycsvpro::header::new()","sycsvpro::inserter::new()","sycsvpro::mapper::new()","sycsvpro::profiler::new()","sycsvpro::scriptcreator::new()","sycsvpro::scriptlist::new()","sycsvpro::sorter::new()","sycsvpro::filter#pivot_each_column()","sycsvpro::columnfilter#process()","sycsvpro::columntypefilter#process()","sycsvpro::filter#process()","sycsvpro::header#process()","sycsvpro::rowfilter#process()","sycsvpro::aggregator#process_aggregation()","sycsvpro::counter#process_count()","sycsvpro::analyzer#result()","dsl#rows()","object#set_max_row()","dsl#str2utf8()","dsl#unstring()","sycsvpro::aggregator#write_result()","sycsvpro::counter#write_result()","dsl#write_to()",""],"info":[["Dsl","","Dsl.html","","<p>Methods to be used in customer specific script files\n"],["Object","","Object.html","",""],["Sycsvpro","","Sycsvpro.html","","<p>Operating csv files\n<p>Operating csv files\n<p>Operating csv files\n"],["Sycsvpro::Aggregator","","Sycsvpro/Aggregator.html","","<p>An Aggregator counts specified row values and adds a sum to the end of the\nrow\n"],["Sycsvpro::Allocator","","Sycsvpro/Allocator.html","","<p>Allocates columns to a key column\n"],["Sycsvpro::Analyzer","","Sycsvpro/Analyzer.html","","<p>Analyzes the file structure\n"],["Sycsvpro::Calculator","","Sycsvpro/Calculator.html","","<p>Processes arithmetic operations on columns of a csv file. A column value\nhas to be a number. Possible …\n"],["Sycsvpro::Collector","","Sycsvpro/Collector.html","","<p>Collects values from rows and groups them in categories\n"],["Sycsvpro::ColumnFilter","","Sycsvpro/ColumnFilter.html","","<p>Creates a new column filter\n"],["Sycsvpro::ColumnTypeFilter","","Sycsvpro/ColumnTypeFilter.html","","<p>Create a filter based on a colum and its type\n"],["Sycsvpro::Counter","","Sycsvpro/Counter.html","","<p>Counter counts values and uses the values as column names and uses the\ncount as the column value\n"],["Sycsvpro::Extractor","","Sycsvpro/Extractor.html","","<p>Extracts rows and columns from a csv file\n"],["Sycsvpro::Filter","","Sycsvpro/Filter.html","","<p>Creates a new filter that can be extended by sub-classes. A sub-class needs\nto override the process method …\n"],["Sycsvpro::Header","","Sycsvpro/Header.html","","<p>Creates a header\n"],["Sycsvpro::Inserter","","Sycsvpro/Inserter.html","","<p>Insert a text file into another textfile at a specified position\n"],["Sycsvpro::Mapper","","Sycsvpro/Mapper.html","","<p>Map values to new values described in a mapping file\n"],["Sycsvpro::Profiler","","Sycsvpro/Profiler.html","","<p>A profiler takes a Ruby script and executes the provided method in the\nscript\n"],["Sycsvpro::RowFilter","","Sycsvpro/RowFilter.html","","<p>Filters rows based on provided patterns\n"],["Sycsvpro::ScriptCreator","","Sycsvpro/ScriptCreator.html","","<p>Creates a ruby script scaffold\n"],["Sycsvpro::ScriptList","","Sycsvpro/ScriptList.html","","<p>Lists the contents of the script directory. Optionally listing a specific\nscript file and also optionally …\n"],["Sycsvpro::Sorter","","Sycsvpro/Sorter.html","","<p>Sorts an input file based on a column sort filter\n"],["execute","Sycsvpro::Aggregator","Sycsvpro/Aggregator.html#method-i-execute","()","<p>Executes the aggregator\n"],["execute","Sycsvpro::Allocator","Sycsvpro/Allocator.html#method-i-execute","()","<p>Executes the allocator and assigns column values to the key\n"],["execute","Sycsvpro::Calculator","Sycsvpro/Calculator.html#method-i-execute","()","<p>Executes the calculator\n"],["execute","Sycsvpro::Collector","Sycsvpro/Collector.html#method-i-execute","()","<p>Execute the collector\n"],["execute","Sycsvpro::Counter","Sycsvpro/Counter.html#method-i-execute","()","<p>Executes the counter\n"],["execute","Sycsvpro::Extractor","Sycsvpro/Extractor.html#method-i-execute","()","<p>Executes the extractor\n"],["execute","Sycsvpro::Inserter","Sycsvpro/Inserter.html#method-i-execute","()","<p>Inserts the content of the insert-file at the specified positions (top or\nbottom)\n"],["execute","Sycsvpro::Mapper","Sycsvpro/Mapper.html#method-i-execute","()","<p>Executes the mapper\n"],["execute","Sycsvpro::Profiler","Sycsvpro/Profiler.html#method-i-execute","(method)","<p>Executes the provided method in the Ruby script\n"],["execute","Sycsvpro::ScriptList","Sycsvpro/ScriptList.html#method-i-execute","()","<p>Retrieves the information about scripts and methods from the script\ndirectory\n"],["execute","Sycsvpro::Sorter","Sycsvpro/Sorter.html#method-i-execute","()","<p>Sorts the data of the infile\n"],["has_filter?","Sycsvpro::Filter","Sycsvpro/Filter.html#method-i-has_filter-3F","()","<p>Checks whether a filter has been set. Returns true if filter has been set\notherwise false\n"],["method_missing","Sycsvpro::Calculator","Sycsvpro/Calculator.html#method-i-method_missing","(id, *args, &block)","<p>Retrieves the values from a row as the result of a arithmetic operation\n"],["method_missing","Sycsvpro::Filter","Sycsvpro/Filter.html#method-i-method_missing","(id, *args, &block)","<p>Creates the filters based on the given patterns\n"],["new","Sycsvpro::Aggregator","Sycsvpro/Aggregator.html#method-c-new","(options={})","<p>Creates a new aggregator. Takes as attributes infile, outfile, key, rows,\ncols, date-format  and indicator …\n"],["new","Sycsvpro::Allocator","Sycsvpro/Allocator.html#method-c-new","(options={})","<p>Creates a new allocator. Options are infile, outfile, key, rows and columns\nto allocate to key\n"],["new","Sycsvpro::Analyzer","Sycsvpro/Analyzer.html#method-c-new","(file)","<p>Creates a new analyzer\n"],["new","Sycsvpro::Calculator","Sycsvpro/Calculator.html#method-c-new","(options={})","<p>Creates a new Calculator. Options expects :infile, :outfile, :rows and\n:columns. Optionally a header …\n"],["new","Sycsvpro::Collector","Sycsvpro/Collector.html#method-c-new","(options={})","<p>Creates a new Collector\n"],["new","Sycsvpro::Counter","Sycsvpro/Counter.html#method-c-new","(options={})","<p>Creates a new counter. Takes as attributes infile, outfile, key, rows,\ncols, date-format and indicator …\n"],["new","Sycsvpro::Extractor","Sycsvpro/Extractor.html#method-c-new","(options={})","<p>Creates a new extractor\n"],["new","Sycsvpro::Filter","Sycsvpro/Filter.html#method-c-new","(values, options={})","<p>Creates a new filter\n"],["new","Sycsvpro::Header","Sycsvpro/Header.html#method-c-new","(header)","<p>Create a new header\n"],["new","Sycsvpro::Inserter","Sycsvpro/Inserter.html#method-c-new","(options={})","<p>Creates an Inserter and takes options infile, outfile, insert-file and\nposition where to insert the insert-file …\n"],["new","Sycsvpro::Mapper","Sycsvpro/Mapper.html#method-c-new","(options={})","<p>Creates new mapper\n"],["new","Sycsvpro::Profiler","Sycsvpro/Profiler.html#method-c-new","(pro_file)","<p>Creates a new profiler\n"],["new","Sycsvpro::ScriptCreator","Sycsvpro/ScriptCreator.html#method-c-new","(options={})","<p>Creates a new ScriptCreator\n"],["new","Sycsvpro::ScriptList","Sycsvpro/ScriptList.html#method-c-new","(options={})","<p>Creates a new ScriptList. Takes params script_dir, script_file and\nshow_methods\n"],["new","Sycsvpro::Sorter","Sycsvpro/Sorter.html#method-c-new","(options={})","<p>Creates a Sorter and takes as options infile, outfile, rows, cols including\ntypes and a date format for …\n"],["pivot_each_column","Sycsvpro::Filter","Sycsvpro/Filter.html#method-i-pivot_each_column","(values=[])","<p>Yields the column value and whether the filter matches the column\n"],["process","Sycsvpro::ColumnFilter","Sycsvpro/ColumnFilter.html#method-i-process","(object, options={})","<p>Processes the filter and returns the values that respect the filter\n"],["process","Sycsvpro::ColumnTypeFilter","Sycsvpro/ColumnTypeFilter.html#method-i-process","(object, options={})","<p>Processes the filter and returns the filtered columns\n"],["process","Sycsvpro::Filter","Sycsvpro/Filter.html#method-i-process","(object, options={})","<p>Processes the filter. Needs to be overridden by the sub-class\n"],["process","Sycsvpro::Header","Sycsvpro/Header.html#method-i-process","(line)","<p>Returns the header\n"],["process","Sycsvpro::RowFilter","Sycsvpro/RowFilter.html#method-i-process","(object, options={})","<p>Processes the filter on the given row\n"],["process_aggregation","Sycsvpro::Aggregator","Sycsvpro/Aggregator.html#method-i-process_aggregation","()","<p>Process the aggregation of the key values\n"],["process_count","Sycsvpro::Counter","Sycsvpro/Counter.html#method-i-process_count","()","<p>Processes the counting on the in file\n"],["result","Sycsvpro::Analyzer","Sycsvpro/Analyzer.html#method-i-result","()","<p>Analyzes the file and returns the result\n"],["rows","Dsl","Dsl.html#method-i-rows","(options={})","<p>Retrieves rows and columns from the file and returns them to the block\nprovided by the caller\n"],["set_max_row","Object","Object.html#method-i-set_max_row","(options, max_row)","<p>the -r flag can take a EOF value which is replaced by the actual row value\nof the input file\n"],["str2utf8","Dsl","Dsl.html#method-i-str2utf8","(str)","<p>Remove non-UTF chars from string\n"],["unstring","Dsl","Dsl.html#method-i-unstring","(line)","<p>Remove leading and trailing “ and spaces as well as reducing more than 2\nspaces between words from …\n"],["write_result","Sycsvpro::Aggregator","Sycsvpro/Aggregator.html#method-i-write_result","()","<p>Writes the aggration results\n"],["write_result","Sycsvpro::Counter","Sycsvpro/Counter.html#method-i-write_result","()","<p>Writes the count results\n"],["write_to","Dsl","Dsl.html#method-i-write_to","(file)","<p>writes values provided by a block to the given file\n"],["README","","README_rdoc.html","","<p>sycsvpro\n<p>Author &mdash; Pierre Sugar (pierre@sugaryourcoffee.de)\n<p>Copyright &mdash; Copyright © 2014 by Pierre Sugar\n"]]}}