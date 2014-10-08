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

  it "is serializeable as JSON" do
    currency = Maguire::Currency.coded("USD")
    json = currency.as_json
    json.delete(:name).must_equal "US Dollar"
    json.delete(:code).must_equal "USD"
    json.delete(:minor_units).must_equal 2
    json.delete(:precision).must_equal 100
    json.delete(:symbol).must_equal '$'
    json.delete(:symbol_html).must_equal nil
    json.must_be_empty
  end
end
