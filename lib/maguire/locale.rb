require 'json'
require 'pry'

module Maguire
  class Locale
    class NotSupportedError < StandardError; end

    attr_reader :code, :symbol, :locale

    def initialize(locale_data={})
      @positive_formatting = parse_layout(locale_data[:layouts][:positive])
      @negative_formatting = parse_layout(locale_data[:layouts][:negative])

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

      formatting[:layout] % {
        symbol: currency.symbol,
        code: currency.code,
        major_value: groups.join(formatting[:digit_grouping_symbol]),
        minor_value: partial.to_i.to_s.rjust(currency.minor_units, "0")
      }
    end

    private

      # Currency layouts are defined using a standard format of:
      # 1234567890.12 USD
      # 1,23,45,67,890.12 USD
      # 12,3456,7890.12 USD
      def parse_layout(layout)
        if layout =~ /([0-9]{2}[^0-9]){3}[0-9]{3}[^0-9]/
          @group_numbers_in_south_asian_style = true
          digit_grouping_symbol = layout.match(/1([^0-9]*)23/)[1]
          layout.gsub!(["1", "23", "45", "67", "890"].join(digit_grouping_symbol), "%{major_value}")
        elsif layout =~ /([0-9]{4}[^0-9])+/
          @group_numbers_in_fours = true
          digit_grouping_symbol = layout.match(/12([^0-9]*)3456/)[1]
          layout.gsub!(["12", "3456", "7890"].join(digit_grouping_symbol), "%{major_value}")
        elsif layout =~ /([0-9]{3}[^0-9]){3}+/
          @group_numbers_in_threes = true
          digit_grouping_symbol = layout.match(/1([^0-9]*)234/)[1]
          layout.gsub!(["1", "234", "567", "890"].join(digit_grouping_symbol), "%{major_value}")
        end

        layout.gsub!("USD", "%{code}")
        layout.gsub!("$", "%{symbol}")
        layout.gsub!("12", "%{minor_value}")

        {
          layout: layout,
          digit_grouping_symbol: digit_grouping_symbol
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
            raise Locale::NotSupportedError.new("The locale #{locale} isn't supported")
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
