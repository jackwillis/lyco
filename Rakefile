require 'bundler'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

desc 'Pry console for test environment'
task :console do
  Bundler.require(:default, :development)
  ENV['RACK_ENV'] = 'test'
  require_relative 'spec/fakes'
  require_relative 'spec/environment'
  require_relative 'application'
  Pry.start
end
