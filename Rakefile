require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :seed do |t|
  require 'nokogiri'
  require 'open-uri'
  require 'json'

  doc = Nokogiri::XML(open("http://www.currency-iso.org/dam/downloads/table_a1.xml"))

  currencies = {}
  doc.xpath('//CcyNtry').each do |entry|
    country_name = entry.xpath('CtryNm/text()').to_s
    currency_name = entry.xpath('CcyNm/text()').to_s
    currency_code = entry.xpath('Ccy/text()').to_s
    currency_number = entry.xpath('CcyNbr/text()').to_s
    number_of_minor_units = entry.xpath('CcyMnrUnts/text()').to_s

    if number_of_minor_units.empty?
      number_of_minor_units = 0
    else
      number_of_minor_units = number_of_minor_units.to_i
    end

    next if currency_code.empty?

    currency = currencies[currency_code.to_sym]
    if currency
      currency[:countries] << country_name
    else
      currencies[currency_code.to_sym] = {
        name: currency_name,
        code: currency_code,
        number: currency_number,
        minor_units: number_of_minor_units,
        countries: [country_name]
      }
    end
  end

  currencies.each do |currency_code, data|
    File.open("iso_data/#{currency_code.to_s.downcase}.json", 'w') do |file|
      file.write(JSON.pretty_generate(data))
    end
  end
end

task default: :test
