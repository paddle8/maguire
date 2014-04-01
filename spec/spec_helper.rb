require 'minitest/spec'
require 'minitest/autorun'

require 'maguire'

def setup_maguire_test_data_path
  Maguire.data_paths.clear
  Maguire.data_paths << maguire_spec_data_path
end

def maguire_spec_data_path
  Maguire.root_path + 'spec_data/iso_data'
end

def setup_maguire_test_locale_path
  Maguire.locale_paths.clear
  Maguire.locale_paths << maguire_spec_locale_path
end

def maguire_spec_locale_path
  Maguire.root_path + 'spec_data/locale'
end

setup_maguire_test_data_path
setup_maguire_test_locale_path
