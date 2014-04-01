require 'json'
require 'pry'

module Maguire
  class Locale
    attr_reader :code, :symbol, :locale

    def initialize(locale_data={})
      @positive_formatting = parse_formatting(locale_data[:formats][:positive])
      @negative_formatting = parse_formatting(locale_data[:formats][:negative])

      locale_data.delete(:formats)
      @currency_overlays = locale_data
    end

    def format(value_in_subunit, currency, options={})
      value_in_unit = value_in_subunit / currency.precision
      partial = round((value_in_subunit / currency.precision.to_f) % 1)

      overlay = @currency_overlays[currency.code.to_sym]
      currency = currency.overlay(overlay) if overlay

      groups = split_value_into_groups(value_in_unit)

      formatting = case
                   when value_in_subunit >= 0
                     @positive_formatting
                   else
                     @negative_formatting
                   end

      display_value = groups.join(formatting[:digit_grouping_symbol]) + formatting[:decimal_symbol] + partial.to_i.to_s.rjust(currency.minor_units, "0")
      currency.symbol + display_value
    end

    private

      # Currency parsing is defined using a standard format of:
      # 1234567890.12
      def parse_formatting(format_string)
        @group_numbers_in_threes = true
        {
          digit_grouping_symbol: ",",
          decimal_symbol: "."
        }
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
        value = value.to_s
        if groups_of_three?
          while value.length > 0
            groups.unshift(value.slice(value.length - 3, value.length))
            value = value.slice(0, value.length - 3)
          end
        elsif groups_of_four?
          while value.length > 0
            groups.unshift(value.slice(value.length - 4, value.length))
            value = value.slice(0, value.length - 4)
          end
        elsif south_asian_grouping?
          groups.unshift(value.slice(value.length - 3, value.length))
          value = value.slice(0, value.length - 3)

          while value.length > 0
            groups.unshift(value.slice(value.length - 2, value.length))
            value = value.slice(0, value.length - 2)
          end
        end
        groups
      end

    class << self

      def clear_cache!
        @cache = {}
      end

      def lookup(options)
        locale = "#{options[:lang].downcase}_#{options[:country].upcase}"

        return @cache[locale.to_sym] if @cache && @cache[locale.to_sym]

        data_sets = Maguire.locale_paths.map do |data_path|
          path = data_path.join("#{locale}.json")

          # If the exact locale file doesn't exist,
          # try to find a suitable backup (ie. for en_FR, choose fr_FR)
          if File.exists?(path)
            JSON.parse(File.read(path), symbolize_names: true)
          else
            []
          end
        end

        @cache[locale.to_sym] = self.new(merge_data(data_sets))
      end

      def merge_data(data_sets)
        data_sets.first
      end
    end
  end
end
