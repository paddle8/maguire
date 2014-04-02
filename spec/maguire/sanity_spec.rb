require 'spec_helper'

describe "default data sanity check" do
  before do
    Maguire.reset_data_paths
    Maguire.reset_locale_paths
  end

  after do
    setup_maguire_test_data_path
    setup_maguire_test_locale_path
  end

  it "can retrieve a currency" do
    usd = Maguire::Currency.coded("USD")
    usd.instance_of?(Maguire::Currency)
    usd.code.must_equal "USD"
    usd.name.must_equal "US Dollar"
    usd.minor_units.must_equal 2
  end

  it "can retrieve a locale" do
    en_US = Maguire::Locale.lookup({ lang: "en", country: "US" })
    en_US.instance_of?(Maguire::Locale)
  end

end
