# -*- coding: utf-8 -*-
require 'spec_helper'

describe Maguire::Locale do
  it "loads a locale from the specified locale directory" do
    locale = Maguire::Locale.lookup({ lang: "en", country: "US" })
    locale.locale.must_equal "en_US"
  end

  it "is serializeable as JSON" do
    locale = Maguire::Locale.lookup({ lang: "en", country: "US" })
    json = locale.as_json

    positive_formatting = json.delete(:positive)
    positive_formatting.delete(:layout).must_equal "%{symbol}%{major_value}%{decimal}%{minor_value}"
    positive_formatting.delete(:decimal_symbol).must_equal "."
    positive_formatting.delete(:digit_grouping_symbol).must_equal ","
    positive_formatting.delete(:digit_grouping_style).must_equal "triples"
    positive_formatting.must_be_empty

    negative_formatting = json.delete(:negative)
    negative_formatting.delete(:layout).must_equal "-%{symbol}%{major_value}%{decimal}%{minor_value}"
    negative_formatting.delete(:decimal_symbol).must_equal "."
    negative_formatting.delete(:digit_grouping_symbol).must_equal ","
    negative_formatting.delete(:digit_grouping_style).must_equal "triples"
    negative_formatting.must_be_empty

    json.delete(:zero).must_be_nil
    json.must_be_empty
  end
end
