# -*- coding: utf-8 -*-
require 'minitest/spec'
require 'minitest/autorun'
require 'maguire'

describe Maguire::Locale do
  it "loads a locale from the specified locale directory" do
    locale = Maguire::Locale.lookup({ lang: "en", country: "US" })
  end

  it "caches currencies" do
    currency = Maguire::Currency.lookup("EUR")
    currency.must_be_same_as Maguire::Currency.lookup("EUR")
    currency.wont_be_same_as Maguire::Currency.lookup("CAD")
  end

  describe "formatting" do
    it "works well without providing any options" do
      locale = Maguire::Locale.lookup({ lang: "en", country: "US" })
      currency = Maguire::Currency.lookup("USD")

      locale.format(500_000_00, currency).must_equal "$500,000.00"
    end

    it "formats foreign currencies in the requested locale correctly" do
      locale = Maguire::Locale.lookup({ lang: "en", country: "US" })
      currency = Maguire::Currency.lookup("EUR")

      locale.format(500_000_00, currency).must_equal "€500,000.00"

      locale = Maguire::Locale.lookup({ lang: "fr", country: "FR" })
      currency = Maguire::Currency.lookup("EUR")

      locale.format(500_000_00, currency).must_equal "500 000,00 €"
    end
  end
end
