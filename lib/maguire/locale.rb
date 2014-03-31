require 'json'

module Maguire
  class Locale
    attr_reader :code, :symbol, :locale

    def initialize(locale_data={})
      @digit_grouping_symbol = ','
      @decimal_symbol = '.'
    end

    def symbol_for(code)
      "$"
    end

    def format(value_in_subunit, currency, options)
      value_in_unit = value_in_subunit / currency.precision.to_f
      partial = round(value_in_subunit - value_in_unit)

      groups = split_value_into_groups(value_in_unit)

      display_value = groups.join(@digit_grouping_symbol) + @decimal_symbol + partial
      symbol_for(code) + display_value
    end

    private

      # Currency parsing is defined using a standard format of:
      # 1234567890.12
      def parse_formatting(format)
        
      end

      def round(value)
        value
      end

      def groups_of_three?
        @group_numbers_in_threes
      end

      def groups_of_four?
        @group_numbers_in_threes
      end

      def south_asian_grouping?
        @group_numbers_in_south_asian_style
      end

      def split_value_into_groups(value)
        groups = []
        if groups_of_three?
          while value > 0
            groups.unshift(value % 100)
            value = value / 100
          end
        elsif groups_of_four?
          while value > 0
            groups.unshift(value % 1000)
            value = value / 1000
          end
        elsif south_asian_grouping?
          groups.unshift(value % 100)
          value = value / 100

          while value > 0
            groups.unshift(value % 10)
            value = value / 10
          end
        end
        groups
      end

  end
end
