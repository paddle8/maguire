require 'json'
require 'pry'

module Maguire
  class Currency
    attr_reader :code

    def initialize(iso_data={})
      iso_data.each do |key, value|
        self.instance_variable_set("@#{key}".to_sym, value)
      end
    end

    def precision
      10 ** @minor_units
    end

    def inspect
      "<##{self.class} code=#{@code}>"
    end

    class << self

      def clear_cache!; end

      def lookup(code)
        code = code.downcase

        data_sets = Maguire.data_paths.map do |data_path|
          path = data_path.join("#{code}.json")
          if File.exists?(path)
            JSON.load(path, nil, symbolize_names: true)
          else
            []
          end
        end

        Currency.new(merge_data(data_sets))
      end

      def merge_data(data_sets)
        data_sets.first
      end
    end
  end
end
