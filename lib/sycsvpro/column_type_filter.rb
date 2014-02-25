module Sycsvpro

  class ColumnTypeFilter < ColumnFilter

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
          values[index] = Date.strptime(value, date_format) unless value.empty?
        end
      end 

      values
    end

  end

end
