# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ratonvirus/clamby/version"

Gem::Specification.new do |spec|
  spec.name = "ratonvirus-clamby"
  spec.version = Ratonvirus::Clamby::VERSION
  spec.authors = ["Antti Hukkanen"]
  spec.email = ["antti.hukkanen@mainiotech.fi"]

  spec.summary = "Clamby scanner for Ratonvirus."
  spec.description = "Provides ClamAV scanner backed by Clamby for the Ratonvirus gem."
  spec.homepage = "https://github.com/mainio/ratonvirus-clamby"
  spec.license = "MIT"

  spec.files = Dir[
    "lib/**/*",
    "CHANGELOG.md",
    "LICENSE",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "clamby", "~> 1.6"
  spec.add_dependency "ratonvirus", "~> 0.2.0"

  # Basic development dependencies.
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  # Code coverage
  spec.add_development_dependency "simplecov", "~> 0.18.0"

  # Rubocop linter
  spec.add_development_dependency "rubocop", "~> 0.86.0"
  spec.add_development_dependency "rubocop-rspec", "~> 1.40"
end
