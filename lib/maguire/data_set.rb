require 'maguire/hash'

module Maguire
  class DataSet
    include Enumerable

    def initialize()
      @cache = {}
      @paths = []
    end

    def each(&block)
      @paths.each(&block)
    end

    def <<(path)
      clear_cache!
      @paths << path
    end

    def clear_cache!
      @cache = {}
    end

    def clear
      clear_cache!
      @paths = []
    end

    def load(id)
      return @cache[id.to_sym] if @cache && @cache[id.to_sym]

      data_sets = map do |data_path|
        path = data_path.join("#{id}.json")
        if File.exists?(path)
          JSON.parse(File.read(path), symbolize_names: true)
        else
          {}
        end
      end

      @cache[id.to_sym] = merge_data(data_sets)
    end

    def merge_data(data_sets)
      merged_set = Maguire::Hash.merge(data_sets)
      if merged_set[:enabled] == false
        nil
      else
        merged_set
      end
    end
  end
end
