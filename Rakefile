# frozen_string_literal: true

require "rspec/core/rake_task"

# Run all tests, with coverage report
RSpec::Core::RakeTask.new(:coverage) do |t|
  ENV["CODECOV"] = "1"
  t.verbose = false
end

# Run all tests, include all
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

# Run both by default
task default: [:spec, :coverage]
