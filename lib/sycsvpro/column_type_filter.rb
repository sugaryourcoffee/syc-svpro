# Operating csv files
module Sycsvpro

  # Create a filter based on a colum and its type
  class ColumnTypeFilter < ColumnFilter

    # Processes the filter and returns the filtered columns
    def process(object, options={})
      filtered = super(object, options)

      return nil if filtered.nil?

      values = filtered.split(';')

      values.each_with_index do |value, index|
        if types[index] == 'n'
          if value =~ /\./
            number_value = value.to_f
          else
            number_value = value.to_i
          end
          values[index] = number_value
        elsif types[index] == 'd'
          if value.strip.empty?
            date = Date.strptime('9999-9-9', '%Y-%m-%d')
          else
            begin
              date = Date.strptime(value, date_format)
            rescue
              puts "Error #{value}, #{index}"
            end
          end
          values[index] = date
        end
      end 

      values
    end

  end

end
