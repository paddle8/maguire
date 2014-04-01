# -*- coding: utf-8 -*-
require 'spec_helper'

describe Maguire::Locale do
  it "loads a locale from the specified locale directory" do
    locale = Maguire::Locale.lookup({ lang: "en", country: "US" })
  end

  describe "formatting" do
    it "works well without providing any options" do
      locale = Maguire::Locale.lookup({ lang: "en", country: "US" })
      currency = Maguire::Currency.lookup("USD")

      locale.format(500_000_00, currency).must_equal "$500,000.00"
    end

    it "formats foreign currencies in the requested locale correctly" do
      en_US = Maguire::Locale.lookup({ lang: "en", country: "US" })
      eur = Maguire::Currency.lookup("EUR")
      usd = Maguire::Currency.lookup("USD")

      en_US.format(500_000_00, eur).must_equal "€500,000.00"
      en_US.format(500_000_00, usd).must_equal "$500,000.00"

      fr_FR = Maguire::Locale.lookup({ lang: "fr", country: "FR" })

      fr_FR.format(500_000_00, eur).must_equal "500 000,00 €"
      fr_FR.format(500_000_00, usd).must_equal "500 000,00 US$"
    end

    it "handles South Asian formatting" do
      en_IN = Maguire::Locale.lookup({ lang: "en", country: "IN" })
      usd = Maguire::Currency.lookup("USD")

      en_IN.format(1_23_45_67_890_12, usd).must_equal "$1,23,45,67,890.12"
    end
  end
end
