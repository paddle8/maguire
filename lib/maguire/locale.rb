require 'json'
require 'pry'

module Maguire
  class Locale
    class NotSupportedError < StandardError; end

    attr_reader :locale, :code, :symbol, :locale

    def initialize(locale, locale_data={})
      @locale = locale

      @positive_formatting = parse_layout(locale_data[:layouts][:positive])
      @negative_formatting = parse_layout(locale_data[:layouts][:negative])

      @currency_overlays = locale_data
    end

    def inspect
      "<##{self.class} locale=#{locale}>"
    end

    def format(value, currency, options={})
      major_value = value.abs / currency.precision
      minor_value = round(value.abs - major_value * currency.precision)

      overlay = @currency_overlays[currency.code.downcase.to_sym]
      currency = currency.overlay(overlay) if overlay

      groups = split_value_into_groups(major_value)
      if groups.compact.length == 0
        binding.pry
      end

      formatting = value >= 0 ?
        @positive_formatting : @negative_formatting

      symbol = currency.symbol
      if options[:html] && currency.symbol_html
        symbol = currency.symbol_html
      end

      strip_insignificant_zeros = options[:strip_insignificant_zeros]
      if options[:no_minor_units] || currency.minor_units == 0
        minor_value = 0
        strip_insignificant_zeros = true
      end

      if strip_insignificant_zeros && minor_value == 0
        minor_value = ""
        decimal_symbol = ""
      else
        minor_value = minor_value.to_s.rjust(currency.minor_units, "0")
        decimal_symbol = formatting[:decimal_symbol]
      end

      formatting[:layout] % {
        symbol: symbol,
        code: currency.code,
        decimal: decimal_symbol,
        major_value: groups.join(formatting[:digit_grouping_symbol]),
        minor_value: minor_value
      }
    end

    private

      SOUTH_ASIAN_GROUPING_RE = /([0-9]{2}[^0-9]){3}[0-9]{3}[^0-9]/
      GROUPS_OF_FOUR_RE = /([0-9]{4}[^0-9])+/
      GROUPS_OF_THREE_RE = /([0-9]{3}[^0-9]){3}+/

      def parse_groups_in_south_asian_style(layout)
        @group_numbers_in_south_asian_style = true
        digit_grouping_symbol = layout.match(/1([^0-9]*)23/)[1]
        layout.gsub!(["1", "23", "45", "67", "890"].join(digit_grouping_symbol), "%{major_value}")
        digit_grouping_symbol
      end

      def parse_groups_of_four(layout)
        @group_numbers_in_fours = true
        digit_grouping_symbol = layout.match(/12([^0-9]*)3456/)[1]
        layout.gsub!(["12", "3456", "7890"].join(digit_grouping_symbol), "%{major_value}")
        digit_grouping_symbol
      end

      def parse_groups_of_three(layout)
        @group_numbers_in_threes = true
        digit_grouping_symbol = layout.match(/1([^0-9]*)234/)[1]
        layout.gsub!(["1", "234", "567", "890"].join(digit_grouping_symbol), "%{major_value}")
        digit_grouping_symbol
      end

      # Currency layouts are defined using a standard format of:
      # 1234567890.12 USD
      # 1,23,45,67,890.12 USD
      # 12,3456,7890.12 USD
      def parse_layout(layout)
        layout = layout.dup

        digit_grouping_symbol =
          if layout =~ SOUTH_ASIAN_GROUPING_RE
            parse_groups_in_south_asian_style(layout)
          elsif layout =~ GROUPS_OF_FOUR_RE
            parse_groups_of_four(layout)
          elsif layout =~ GROUPS_OF_THREE_RE
            parse_groups_of_three(layout)
          end

        layout.gsub!("USD", "%{code}")
        layout.gsub!("$", "%{symbol}")
        layout.gsub!("12", "%{minor_value}")
        decimal_symbol = layout.match(/major_value}(.*)%{minor_value/)[1]
        layout.gsub!(decimal_symbol, "%{decimal}")

        {
          layout: layout,
          decimal_symbol: decimal_symbol,
          digit_grouping_symbol: digit_grouping_symbol
        }
      end

      def round(value)
        value.to_i
      end

      def break_off(value, number)
        len = value.length
        number = len if number > len
        [value.slice(0, len - number), value.slice(len - number, len)]
      end

      def split_value_into_groups_of(value, number)
        groups = []
        while value && value.length > 0
          (value, partial) = break_off(value, number)
          groups.unshift(partial)
        end
        groups
      end

      def split_value_into_groups(value)
        value = value.to_s

        if @group_numbers_in_threes
          split_value_into_groups_of(value, 3)
        elsif @group_numbers_in_fours
          split_value_into_groups_of(value, 4)
        elsif @group_numbers_in_south_asian_style
          (value, partial) = break_off(value, 3)

          split_value_into_groups_of(value, 2) << partial
        else
          []
        end
      end

    class << self
      def lookup(options)
        locale = "#{options[:lang].downcase}_#{options[:country].upcase}"
        data = Maguire.locale_paths.load(locale)
        if data.nil?
          raise Locale::NotSupportedError.new("The locale #{locale} isn't supported")
        else
          self.new(locale, data)
        end
      end
    end
  end
end
