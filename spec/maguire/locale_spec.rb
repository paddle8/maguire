# -*- coding: utf-8 -*-
require 'spec_helper'

describe Maguire::Locale do
  it "loads a locale from the specified locale directory" do
    locale = Maguire::Locale.lookup({ lang: "en", country: "US" })
    locale.locale.must_equal "en_US"
  end
end
