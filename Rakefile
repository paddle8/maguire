require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task default: :test
