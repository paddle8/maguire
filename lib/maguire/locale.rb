require 'json'

module Maguire
  class Locale
    class NotSupportedError < StandardError; end

    attr_reader :locale, :code, :symbol, :locale

    def initialize(locale, locale_data={})
      @locale = locale

      layouts = locale_data[:layouts]
      @positive_formatting = parse_layout(layouts[:positive])
      @negative_formatting = parse_layout(layouts[:negative])
      if layouts[:zero]
        @zero_formatting = parse_zero_layout(layouts[:zero])
      end

      @currency_overlays = locale_data
    end

    def inspect
      "<##{self.class} locale=#{locale}>"
    end

    def localized_currency(currency_code)
      currency_code.downcase!
      currency = Currency.coded(currency_code)
      overlay = @currency_overlays[currency_code.to_sym]
      if overlay
        currency.overlay(overlay)
      else
        currency
      end
    end

    def format(value, currency_code, options={})
      currency = localized_currency(currency_code)

      major_value = value.abs / currency.precision
      minor_value = round(value.abs - major_value * currency.precision)

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
        decimal_symbol = formatting[:decimal_symbol]

        if minor_value == 0 && @zero_formatting
          formatting = @zero_formatting
        else
          minor_value = minor_value.to_s.rjust(currency.minor_units, "0")
        end
      end

      groups = split_value_into_groups(major_value, formatting[:digit_grouping_style])

      formatting[:layout] % {
        symbol: symbol,
        code: currency.code,
        decimal: decimal_symbol,
        major_value: groups.join(formatting[:digit_grouping_symbol]),
        minor_value: minor_value
      }
    end

    def as_json
      {
        positive: @positive_formatting,
        negative: @negative_formatting,
        zero: @zero_formatting
      }
    end

    private

      SOUTH_ASIAN_GROUPING_RE = /([0-9]{2}[^0-9]){3}[0-9]{3}[^0-9]/
      GROUPS_OF_FOUR_RE = /([0-9]{4}[^0-9])+/
      GROUPS_OF_THREE_RE = /([0-9]{3}[^0-9]){3}+/

      def parse_groups_in_south_asian_style(layout)
        digit_grouping_symbol = layout.match(/1([^0-9]*)23/)[1]
        layout.gsub!(["1", "23", "45", "67", "890"].join(digit_grouping_symbol), "%{major_value}")
        digit_grouping_symbol
      end

      def parse_groups_of_four(layout)
        digit_grouping_symbol = layout.match(/12([^0-9]*)3456/)[1]
        layout.gsub!(["12", "3456", "7890"].join(digit_grouping_symbol), "%{major_value}")
        digit_grouping_symbol
      end

      def parse_groups_of_three(layout)
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
            digit_grouping_style = 'south_asian'
            parse_groups_in_south_asian_style(layout)
          elsif layout =~ GROUPS_OF_FOUR_RE
            digit_grouping_style = 'quadruples'
            parse_groups_of_four(layout)
          elsif layout =~ GROUPS_OF_THREE_RE
            digit_grouping_style = 'triples'
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
          digit_grouping_symbol: digit_grouping_symbol,
          digit_grouping_style: digit_grouping_style
        }
      end

      def parse_zero_layout(layout)
        layout = layout.dup

        layout.gsub!("USD", "%{code}")
        layout.gsub!("$", "%{symbol}")
        layout.gsub!("1", "%{major_value}")
        decimal_symbol = @positive_formatting[:decimal_symbol]
        layout.gsub!(decimal_symbol, "%{decimal}")

        {
          layout: layout,
          decimal_symbol: decimal_symbol,
          digit_grouping_symbol: @positive_formatting[:digit_grouping_symbol],
          digit_grouping_style: @positive_formatting[:digit_grouping_style]
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

      def split_value_into_groups(value, style)
        value = value.to_s

        case(style)
        when 'triples'
          split_value_into_groups_of(value, 3)
        when 'quadruples'
          split_value_into_groups_of(value, 4)
        when 'south_asian'
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
