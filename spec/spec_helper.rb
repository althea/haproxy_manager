require 'rspec'
require 'mocha'
require File.expand_path('../../lib/haproxy_manager', __FILE__)

RSpec.configure do |config|
  config.mock_framework = :mocha
end