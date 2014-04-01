# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "maguire/version"

Gem::Specification.new do |s|
  s.name = %q{maguire}
  s.summary = %q{Locale-specific currency formatting for Ruby}
  s.description = %q{Currency data acquired from the Swiss Association for Standardization}
  s.version = Maguire::VERSION
  s.authors = ["Tim Evans"]
  s.email = %q{tim.c.evans@me.com}
  s.homepage = %q{http://github.com/paddle8/maguire}

  s.required_rubygems_version = ">= 1.3.6"
  s.require_paths = ["lib"]
  s.files = Dir.glob("{lib,iso_data,locale}/**/*") + %w(LICENSE README.md)

  s.add_development_dependency("minitest", ["= 2.6.1"])
  s.add_development_dependency("nokogiri")
  s.add_development_dependency("pry")
  s.add_development_dependency("rake", "0.9.2.2")
end
