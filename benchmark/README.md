# I18nOnSteroids Benchmarks

Performance benchmarks for the I18nOnSteroids gem.

## Setup

```bash
# Install dependencies (including benchmark-ips)
gem install benchmark-ips

# Or with bundle
bundle install
```

## Running Benchmarks

```bash
# Run the performance benchmark suite
BUNDLE_GEMFILE=gemfiles/ruby_3_plus.gemfile bundle exec ruby benchmark/performance.rb
```

## Benchmark Categories

The benchmark suite tests the following scenarios:

1. **Simple Interpolation** - Baseline performance without pipes
2. **Single Pipe** - Performance with one pipe transformation
3. **Multiple Pipes** - Chained pipe transformations
4. **Conditional Pipes** - Impact of if/unless conditions
5. **Pipe Composition** - Variable interpolations in parameters
6. **Complex Translations** - Real-world usage with multiple features
7. **Cache Effectiveness** - Impact of pipe cache on repeated translations

## Performance Tips

### Enable Caching
The pipe cache is automatically enabled and significantly improves performance for repeated translations:

```ruby
# Cache is cleared only when:
# - New pipes are registered
# - Pipe separator changes
# - Manually cleared via TranslationHelper.clear_pipe_cache!
```

### Optimization Best Practices

1. **Pre-compile Translations**: Load translations once at boot
2. **Reuse Options**: Pass the same options hash for similar translations
3. **Minimize Pipes**: Each pipe adds overhead, use only what's needed
4. **Use Built-in Pipes**: Custom pipes have calling overhead
5. **Disable Debug Mode**: Only enable debug_mode during development

### Expected Performance

On typical hardware (2020+ laptop):

- Simple interpolations: ~100K-300K ops/sec
- Single pipe: ~50K-150K ops/sec
- Multiple pipes: ~20K-80K ops/sec
- Complex translations: ~10K-40K ops/sec

Cache hits are typically 10-50% faster than cache misses.

## Profiling

For detailed profiling:

```bash
# Using ruby-prof
gem install ruby-prof
ruby-prof --mode=wall benchmark/performance.rb

# Using stackprof
gem install stackprof
bundle exec ruby -rstackprof -e 'StackProf.run(out: "tmp/stackprof.dump") { load "benchmark/performance.rb" }'
stackprof tmp/stackprof.dump --text
```

## Contributing

When adding new features:

1. Add relevant benchmarks to `performance.rb`
2. Run benchmarks before and after changes
3. Document any performance impact
4. Consider adding specialized benchmarks for complex features
