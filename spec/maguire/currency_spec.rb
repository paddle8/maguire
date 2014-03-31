require 'minitest/spec'
require 'minitest/autorun'
require 'maguire'

describe Maguire::Currency do
  it "loads a currency from the specified data directory" do
    currency = Maguire::Currency.lookup("USD")
    currency.code.must_equal "USD"
    currency.precision.must_equal 100

    currency = Maguire::Currency.lookup("JPY")
    currency.code.must_equal "JPY"
    currency.precision.must_equal 1
  end
end
