require 'minitest/spec'
require 'minitest/autorun'
require 'maguire'

describe Maguire do
  Maguire.data_paths.each do |path|
    Dir.glob("#{path}/*.json") do |filename|
      describe File.basename(filename) do
        it "has valid JSON" do
          JSON.parse(File.open(filename).read)
        end
      end
    end
  end
end
