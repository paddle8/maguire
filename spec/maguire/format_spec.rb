# -*- coding: utf-8 -*-
require 'spec_helper'

describe "formatting a currency" do
  it "works well without providing any options" do
    Maguire.format(value: 500_000_00, currency: "USD").must_equal "$500,000.00"
  end

  it "formats foreign currencies in the requested locale correctly" do
    Maguire.format({
      value: 500_000_00,
      currency: "EUR"
    }, { locale: { lang: "en", country: "US" }}).must_equal "€500,000.00"
    Maguire.format({
      value: 500_000_00,
      currency: "USD"
    }, { locale: { lang: "en", country: "US" }}).must_equal "$500,000.00"

    Maguire.format({
      value: 500_000_00,
      currency: "EUR"
    }, { locale: { lang: "fr", country: "FR" }}).must_equal "500 000,00 €"
    Maguire.format({
      value: 500_000_00,
      currency: "USD"
    }, { locale: { lang: "fr", country: "FR" }}).must_equal "500 000,00 US$"
  end

  it "handles South Asian formatting" do
    Maguire.format({
      value: 1_23_45_67_890_12,
      currency: "USD"
    }, { locale: { lang: "en", country: "IN" }}).must_equal "$1,23,45,67,890.12"
  end

  it "handles formatting old style Chinese / Japanese formatting" do
    Maguire.format({
      value: 12_3456_7890_12,
      currency: "USD"
    }, { locale: { lang: "ja", country: "JP" }}).must_equal "12,3456,7890.12$"
  end

  it "returns the symbol encoded in HTML when the html option is passed" do
    Maguire.format({
      value: 1,
      currency: "EUR"
    }, { html: true }).must_equal "&euro;0.01"
  end

  it "doesn't show the minor units when no_minor_units is set to true" do
    Maguire.format({
      value: 1,
      currency: "USD"
    }, { no_minor_units: true }).must_equal "$0"
  end

  it "only shows the minor units when there are minor units when strip_significant_whitespace is set to true" do
    Maguire.format({
      value: 1,
      currency: "USD"
    }, { strip_insignificant_zeros: true }).must_equal "$0.01"

    Maguire.format({
      value: 100,
      currency: "USD"
    }, { strip_insignificant_zeros: true }).must_equal "$1"
  end

  it "doesn't show the decimal symbol nor minor units when there are no minor units in the currency" do
    Maguire.format({
      value: 1,
      currency: "DOGE"
    }).must_equal "D1"
  end

  it "handles custom formatting when the minor unit is 0" do
    Maguire.format({
      value: 100000,
      currency: "USD"
    }, { locale: { lang: "en", country: "NO" } }).must_equal "$ 1.000,-"
  end

end
