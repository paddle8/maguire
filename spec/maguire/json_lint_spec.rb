require 'spec_helper'

describe Maguire do
  Dir.glob("#{Maguire.root_path}/**/*.json") do |filename|
    describe File.basename(filename) do
      it "has valid JSON" do
        JSON.parse(File.open(filename).read)
      end
    end
  end
end
