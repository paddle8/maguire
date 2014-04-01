require 'json'
require 'pathname'

lib_path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib_path)

require 'maguire/currency'
require 'maguire/data_set'
require 'maguire/locale'
require 'maguire/version'

module Maguire
  class << self

    attr_accessor :root_path, :data_paths, :locale_paths, :default_locale

    def reset_data_paths
      data_paths.clear
      data_paths << root_path + 'iso_data'
    end

    def reset_locale_paths
      locale_paths.clear
      locale_paths << root_path + 'locale'
    end

    def format(money, options={})
      currency = Currency.lookup(money[:currency].downcase)
      locale = Locale.lookup(options[:locale] || Maguire.default_locale)

      locale.format(money[:value], currency, options)
    end
  end

  self.root_path = Pathname.new(__FILE__) + '../..'

  self.data_paths = Maguire::DataSet.new
  self.reset_data_paths

  self.locale_paths = Maguire::DataSet.new
  self.reset_locale_paths

  self.default_locale = {
    lang: "en",
    country: "US"
  }
end
