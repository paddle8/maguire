module Maguire
  module Hash
    def self.merge(hashes)
      return hashes.first if hashes.size == 1

      hashes.inject do |acc, hash|
        acc.merge(hash) do |key, old_value, new_value|
          new_value || old_value
        end
      end
    end
  end
end
