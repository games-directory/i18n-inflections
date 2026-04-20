#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "benchmark/ips"
require "i18n"
require "i18n_on_steroids"

# Setup I18n
I18n.backend.store_translations(:en, {
                                  simple: "Hello %{name}",
                                  with_pipes: "Hello ${name | upcase}",
                                  multiple_pipes: "User: ${name | titleize | truncate: 20}",
                                  conditional: "Status: ${status | upcase if: admin}",
                                  composition: "${count | pluralize: ${unit}}",
                                  complex: "${created_at | date_format: %Y-%m-%d} - ${title | titleize | truncate: 50}"
                                })

# Include translation helper at top level for benchmarking
include I18nOnSteroids::TranslationHelper # rubocop:disable Style/MixinUsage

puts "=" * 80
puts "I18nOnSteroids Performance Benchmarks"
puts "=" * 80
puts

# Benchmark 1: Simple interpolation (no pipes)
puts "1. Simple interpolation (baseline)"
Benchmark.ips do |x|
  x.report("simple") do
    translate(:simple, name: "John")
  end
end
puts

# Benchmark 2: Single pipe
puts "2. Single pipe transformation"
Benchmark.ips do |x|
  x.report("single pipe") do
    translate(:with_pipes, name: "john")
  end
end
puts

# Benchmark 3: Multiple pipes
puts "3. Multiple chained pipes"
Benchmark.ips do |x|
  x.report("multiple pipes") do
    translate(:multiple_pipes, name: "john doe")
  end
end
puts

# Benchmark 4: Conditional pipes
puts "4. Conditional pipe execution"
Benchmark.ips do |x|
  x.report("with condition true") do
    translate(:conditional, status: "active", admin: true)
  end

  x.report("with condition false") do
    translate(:conditional, status: "active", admin: false)
  end

  x.compare!
end
puts

# Benchmark 5: Pipe composition
puts "5. Pipe composition (interpolated parameters)"
Benchmark.ips do |x|
  x.report("composition") do
    translate(:composition, count: 5, unit: "item")
  end
end
puts

# Benchmark 6: Complex translation
puts "6. Complex translation (multiple features)"
Benchmark.ips do |x|
  x.report("complex") do
    translate(:complex, created_at: Time.now, title: "a very long title that will be truncated")
  end
end
puts

# Benchmark 7: Cache effectiveness
puts "7. Cache effectiveness (repeated translations)"
Benchmark.ips do |x|
  x.report("first call (cache miss)") do
    I18nOnSteroids::TranslationHelper.clear_pipe_cache!
    translate(:multiple_pipes, name: "john doe")
  end

  x.report("repeated calls (cache hit)") do
    translate(:multiple_pipes, name: "john doe")
  end

  x.compare!
end
puts

puts "=" * 80
puts "Benchmark completed!"
puts "=" * 80
