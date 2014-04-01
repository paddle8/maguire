require 'json'
require 'pathname'

lib_path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib_path)

require 'maguire/currency'
require 'maguire/locale'
require 'maguire/version'

module Maguire
  class << self

    attr_accessor :data_paths, :locale_paths, :default_locale

    def data_paths
      @data_paths
    end

    # Public: Set the array of paths for Maguire to search for data files.
    def data_paths=(paths)
      Currency.clear_cache!
      @data_paths = paths
    end

    def locale_paths
      @locale_paths
    end

    # Public: Set the array of paths for Maguire to search for data files.
    def locale_paths=(paths)
      Locale.clear_cache!
      @locale_paths = paths
    end

    attr_accessor :root_path

    def append_data_paths(paths)
      Currency.clear_cache!
      self.data_paths = self.data_paths.concat([paths].flatten)
    end

    def clear_data_paths
      Currency.clear_cache!
      self.data_paths = []
    end

    def reset_data_paths
      clear_data_paths
      append_data_paths(root_path + 'iso_data')
    end

    def append_locale_paths(paths)
      Locale.clear_cache!
      self.locale_paths = self.locale_paths.concat([paths].flatten)
    end

    def clear_locale_paths
      Locale.clear_cache!
      self.locale_paths = []
    end

    def reset_locale_paths
      clear_locale_paths
      append_locale_paths(root_path + 'locale')
    end

    def format(money, options={})
      currency = Currency.lookup(money[:currency].downcase)
      locale = Locale.lookup(options[:locale] || Maguire.default_locale)

      locale.format(money[:value], currency, options)
    end
  end

  self.root_path = Pathname.new(__FILE__) + '../..'

  self.reset_data_paths
  self.reset_locale_paths
  self.default_locale = {
    lang: "en",
    country: "US"
  }
end
