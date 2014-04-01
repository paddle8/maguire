require 'json'
require 'ostruct'

module Maguire
  class Currency < OpenStruct
    def initialize(iso_data={})
      @data = iso_data
      super
    end

    def precision
      10 ** minor_units
    end

    def inspect
      "<##{self.class} name=#{name} code=#{code}>"
    end

    def overlay(locale_data={})
      Currency.new(self.class.merge_data(@data, locale_data))
    end

    class << self
      def clear_cache!
        @cache = {}
      end

      def lookup(code)
        return @cache[code.to_sym] if @cache && @cache[code.to_sym]

        data_sets = Maguire.data_paths.map do |data_path|
          path = data_path.join("#{code}.json")
          if File.exists?(path)
            JSON.parse(File.read(path), symbolize_names: true)
          else
            []
          end
        end

        @cache[code.to_sym] = self.new(merge_data(data_sets))
      end

      def merge_data(data_sets)
        data_sets.first
      end
    end
  end
end
