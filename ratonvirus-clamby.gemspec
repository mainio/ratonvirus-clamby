# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ratonvirus/clamby/version"

Gem::Specification.new do |spec|
  spec.name = "ratonvirus-clamby"
  spec.version = Ratonvirus::Clamby::VERSION
  spec.required_ruby_version = ">= 3.2"
  spec.authors = ["Antti Hukkanen"]
  spec.email = ["antti.hukkanen@mainiotech.fi"]

  spec.summary = "Clamby scanner for Ratonvirus."
  spec.description = "Provides ClamAV scanner backed by Clamby for the Ratonvirus gem."
  spec.homepage = "https://github.com/mainio/ratonvirus-clamby"
  spec.license = "MIT"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "lib/**/*",
    "CHANGELOG.md",
    "LICENSE",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "clamby", "~> 1.6"
  spec.add_dependency "ratonvirus", "~> 0.6.0"
end
