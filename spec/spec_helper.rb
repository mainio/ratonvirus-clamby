# frozen_string_literal: true

require 'simplecov' if ENV['SIMPLECOV'] || ENV['CODECOV']
if ENV['CODECOV']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'ratonvirus'
require 'ratonvirus/clamby'

RSpec.configure do |config|
  config.before(:each) do
    # Reset the config before each test
    Ratonvirus.reset

    # Configure a storage backend to be able to call scanner.virus?
    Ratonvirus.configure do |config|
      config.storage = :filepath
      config.addons = []
    end
  end
end
