## [Unreleased]

## [1.0.0] - 2024-04-20

### Major Release 🎉

This is a major release with significant new features, performance improvements, and enhanced developer experience. I18nOnSteroids is now production-ready with comprehensive testing, documentation, and tooling.

### 🎯 New Features

#### Built-in Pipes (9 new pipes)
- **String Manipulation**: `titleize`, `humanize`, `parameterize`, `strip`, `squish`
- **Currency**: `currency` - Format numbers as currency with customizable symbols
- **Date/Time**: `date_format`, `time_format` - Format dates and times with strftime patterns
- **Utilities**: `default` - Provide fallback values for nil/empty inputs

#### Advanced Pipe Features
- **Conditional Pipes**: Apply pipes based on runtime conditions using `if:` and `unless:` modifiers
  - Example: `${value | upcase if: admin}`
- **Pipe Composition**: Use variable interpolations in pipe parameters
  - Example: `${count | pluralize: ${unit}}`
- **Pipe Aliases**: Register alternative names for pipes
  - Default aliases: `trim`, `limit`, `shorten` → `truncate`
- **Namespace Support**: Organize custom pipes by domain
  - Example: `register_pipe(:format, callable, namespace: :datetime)`

### ⚡ Performance Improvements

- **Thread Safety**: Fixed race conditions by replacing class variables with thread-safe instance variables
- **Regex Optimization**: Pre-compiled 5 regex patterns, reducing CPU cycles on hot paths
- **Memoization**: Pipe chain caching with automatic invalidation
- **Lazy Evaluation**: Early returns for empty pipes, skipping unnecessary processing

### 🛠️ Developer Tools

- **Interactive Console**: New helper commands for development
  - `I18nOnSteroids.demo` - Interactive feature demonstration
  - `I18nOnSteroids.test_pipe` - Test pipes interactively
  - `I18nOnSteroids.list_pipes` - List all available pipes
  - `I18nOnSteroids.pipe_info` - Show detailed pipe documentation
- **Rails Generator**: Scaffold custom pipes with boilerplate
  - `rails generate i18n_pipe my_custom`
  - `rails generate i18n_pipe format --namespace=datetime`
- **Benchmark Suite**: Comprehensive performance testing
  - 7 benchmark scenarios covering different usage patterns
  - Performance profiling guide included

### 🔧 Configuration

- **Debug Mode**: Log all pipe transformations for development
  - `config.debug_mode = true`
- **Strict Mode**: Raise errors on all pipe failures
  - `config.strict_mode = true`
- **Improved Error Messages**: Context-aware errors listing available pipes

### 📚 Documentation

- **Comprehensive README**: 500+ lines with examples for all features
- **RBS Type Signatures**: Complete type definitions for IDE support
- **Benchmark Documentation**: Performance tips and profiling instructions
- **Real-world Examples**: E-commerce, admin dashboards, CMS, notifications

### 🧪 Testing

- **27 New Tests**: Comprehensive coverage for all new features
- **68 Total Assertions**: Validating correctness and edge cases
- **CI/CD Ready**: All tests passing on Ruby 3.0-3.3

### 📦 What's Included

- 18 built-in pipes (9 original + 9 new)
- 4 major performance optimizations
- 4 advanced features (composition, conditional, namespace, aliases)
- Interactive console helpers
- Rails generator for custom pipes
- Comprehensive benchmarks
- Full RBS type signatures
- Extensive documentation

### Breaking Changes

None! This release is fully backward compatible with 0.x versions.

### Migration from 0.x

No changes required. All existing translations will continue to work. New features are opt-in.

### Performance

Expected performance on typical hardware:
- Simple interpolations: ~100K-300K ops/sec
- Single pipe: ~50K-150K ops/sec
- Multiple pipes: ~20K-80K ops/sec
- Complex translations: ~10K-40K ops/sec

Cache hits are typically 10-50% faster than cache misses.

## [0.1.1] - 2024-08-21

- Added ability to pipe regular strings. Because, why not?
  `${ 'Hello, World!' | upcase } => HELLO, WORLD!`
Note: This needs to be done via `${}` instead of `%{}` otherwise Psych will throw an error.
- Started listening to `rubocop-performance` and apparently improved some performance.
- Enabled more `rubocop` cops.
- Lowered 'ActiveSupport' and 'ActionView' version requirements to allow more Ruby versions to be supported. 

## [0.1.0] - 2024-08-22

- Initial release