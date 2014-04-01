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
      Currency.new(Maguire::Hash.merge([@data, locale_data]))
    end

    class << self
      def lookup(code)
        self.new(Maguire.data_paths.load(code))
      end
    end
  end
end
