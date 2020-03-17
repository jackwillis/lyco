desc 'open application console with pry'
task :console do
  Bundler.require(:default, :development)
  ENV['RACK_ENV'] = 'test'
  require_relative 'spec/fakes'
  require_relative 'spec/environment'
  require_relative 'config/application'
  Pry.start
end
