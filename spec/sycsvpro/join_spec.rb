require 'sycsvpro/join'

module Sycsvpro

  describe Join do

    before do
      @in_file = File.join(File.dirname(__FILE__), "files/persons.csv")
      @source_file = File.join(File.dirname(__FILE__), "files/countries.csv")
      @out_file = File.join(File.dirname(__FILE__), "files/persons-countries.csv")
    end

    it "should join files based on person ID" do
      cols           = "1,2"
      insert_col_pos = "2,1"
      insert_header  = "COUNTRY,STATE"
      header         = "*"
      joins          = "0=1"
      rows           = "1-4"

      Sycsvpro::Join.new(infile:         @in_file,
                         outfile:        @out_file,
                         source:         @source_file,
                         cols:           cols,
                         joins:          joins,
                         insert_header:  insert_header,
                         insert_col_pos: insert_col_pos,
                         header:         header,
                         rows:           rows).execute

      result = [ "Name;STATE;COUNTRY;N_ID",
                 "Hank;A4;AT;123",
                 "Frank;C3;CA;234",
                 "Mia;D1;DE;345",
                 "Arwen;U2;US;456" ]

      rows = 0

      File.new(@out_file, 'r').each_with_index do |line, index|
        expect(line.chomp).to eq result[index]
        rows += 1
      end 

      rows.should eq result.size

    end

  end
  
end
