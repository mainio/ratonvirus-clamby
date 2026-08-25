# frozen_string_literal: true

source "https://rubygems.org"

gem "ratonvirus", github: "mainio/ratonvirus", branch: "fix/activestorage-attach-scan"

group :development do
  # Basic development dependencies.
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.0"

  # Code coverage
  gem "simplecov", "~> 0.18.0"

  # Rubocop linter
  gem "rubocop", "~> 1.65"
  gem "rubocop-rspec", "~> 3.0"
end

group :test do
  gem "simplecov-cobertura"

  # Fix issue with simplecov-cobertura
  # See: https://github.com/jessebs/simplecov-cobertura/pull/44
  gem "rexml", "3.4.1"
end

gemspec
