require 'spec_helper'

describe Maguire::Currency do
  it "loads a currency from the specified data directory" do
    currency = Maguire::Currency.coded("USD")
    currency.code.must_equal "USD"
    currency.name.must_equal "US Dollar"
    currency.precision.must_equal 100

    currency = Maguire::Currency.coded("EUR")
    currency.code.must_equal "EUR"
    currency.name.must_equal "Euro"
    currency.precision.must_equal 100
  end
end
