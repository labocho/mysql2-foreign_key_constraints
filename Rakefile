# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require File.expand_path "#{File.dirname(__FILE__)}/lib/foreign_key_constraints/version"
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "mysql2-foreign_key_constraints"
  gem.version = Mysql2::ForeignKeyConstraints::Version::STRING
  gem.homepage = "http://github.com/labocho/mysql2-foreign_key_constraints"
  gem.license = "MIT"
  gem.summary = %Q{Add foreign key constraints helper methods to ActiveRecord migration for mysql2 adapter.}
  gem.description = %Q{Add foreign key constraints helper methods to ActiveRecord migration for mysql2 adapter.}
  gem.email = "labocho@penguinlab.jp"
  gem.authors = ["labocho"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mysql2-foreign_key_constraints #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
