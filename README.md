# I18nOnSteroids

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0-ruby.svg)](https://www.ruby-lang.org/en/)
[![Rails](https://img.shields.io/badge/rails-%3E%3D%207.0-red.svg)](https://rubyonrails.org/)

I18nOnSteroids is a Ruby gem that supercharges Rails' I18n functionality with advanced interpolation and piping features. Transform your translations with powerful data manipulation, conditional logic, and composable transformations—all directly in your locale files.

## Features

✨ **18 Built-in Pipes** - String manipulation, formatting, dates, currency, and more
🔗 **Pipe Composition** - Dynamic parameters with variable interpolations
🎯 **Conditional Pipes** - Apply transformations based on runtime conditions
🏷️ **Namespaced Pipes** - Organize custom pipes by domain
⚡ **High Performance** - Thread-safe with memoization and lazy evaluation
🛠️ **Developer Tools** - Interactive console, generator, and benchmarks
🔧 **Highly Configurable** - Debug mode, strict mode, custom pipes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'i18n_on_steroids'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install i18n_on_steroids
```

## Quick Start

Once installed, I18nOnSteroids automatically enhances your Rails I18n functionality.

### Basic Pipes

Use `${}` for advanced interpolation with pipes:

```yaml
en:
  users:
    count: "There are ${count | number_with_delimiter} users"
    greeting: "Hello ${name | titleize}!"
```

```ruby
t('users.count', count: 1000)
# => "There are 1,000 users"

t('users.greeting', name: 'john doe')
# => "Hello John Doe!"
```

### Chained Pipes

Chain multiple transformations:

```yaml
en:
  posts:
    title: "${title | titleize | truncate: 50}"
```

```ruby
t('posts.title', title: 'a very long blog post title that needs truncation')
# => "A Very Long Blog Post Title That Needs..."
```

### Conditional Pipes

Apply pipes based on conditions:

```yaml
en:
  admin:
    status: "${message | upcase if: admin}"
    secret: "${data | default: N/A unless: authorized}"
```

```ruby
t('admin.status', message: 'confidential', admin: true)
# => "CONFIDENTIAL"

t('admin.status', message: 'confidential', admin: false)
# => "confidential"
```

### Pipe Composition

Use variable interpolations in pipe parameters:

```yaml
en:
  items:
    count: "${number | pluralize: ${unit}}"
    price: "${amount | currency: ${symbol}}"
```

```ruby
t('items.count', number: 5, unit: 'item')
# => "5 items"

t('items.price', amount: 99.99, symbol: '€')
# => "€99.99"
```

## Available Pipes

### String Manipulation

| Pipe | Description | Example |
|------|-------------|---------|
| `upcase` | Convert to uppercase | `${name \| upcase}` |
| `downcase` | Convert to lowercase | `${NAME \| downcase}` |
| `capitalize` | Capitalize first character | `${text \| capitalize}` |
| `titleize` | Convert to title case | `${text \| titleize}` |
| `humanize` | Make string human-readable | `${field_name \| humanize}` |
| `parameterize` | Convert to URL-safe format | `${title \| parameterize}` |
| `strip` | Remove leading/trailing whitespace | `${text \| strip}` |
| `squish` | Remove excess whitespace | `${text \| squish}` |
| `truncate` | Limit string length | `${text \| truncate: 50}` |

**Aliases**: `truncate` → `trim`, `limit`, `shorten`

### Numbers & Currency

| Pipe | Description | Example |
|------|-------------|---------|
| `number_with_delimiter` | Format with thousands separator | `${count \| number_with_delimiter}` |
| `round` | Round to precision | `${number \| round: 2}` |
| `currency` | Format as currency | `${price \| currency: €}` |

### Dates & Times

| Pipe | Description | Example |
|------|-------------|---------|
| `date_format` | Format date with strftime | `${date \| date_format: %Y-%m-%d}` |
| `time_format` | Format time with strftime | `${time \| time_format: %H:%M:%S}` |

### Text Processing

| Pipe | Description | Example |
|------|-------------|---------|
| `pluralize` | Pluralize word based on count | `${word \| pluralize: %{count}}` |
| `format` | Apply format string | `${value \| format: %.2f}` |
| `default` | Provide fallback for nil/empty | `${optional \| default: N/A}` |

### Rails Helpers

| Pipe | Description | Example |
|------|-------------|---------|
| `html_safe` | Mark string as HTML safe | `${html \| html_safe}` |

## Advanced Features

### Custom Pipes

Register your own pipes:

```ruby
# config/initializers/i18n_on_steroids.rb
I18nOnSteroids::TranslationHelper.register_pipe(:reverse, ->(value, params, options) {
  value.to_s.reverse
})
```

Use in translations:

```yaml
en:
  fun:
    backwards: "${text | reverse}"
```

### Namespaced Pipes

Organize pipes by domain to avoid naming conflicts:

```ruby
I18nOnSteroids::TranslationHelper.register_pipe(
  :format,
  ->(value, params, options) { value.strftime(params) },
  namespace: :datetime
)
```

```yaml
en:
  events:
    date: "${created_at | datetime.format: %B %d, %Y}"
```

### Pipe Aliases

Create shortcuts for commonly used pipes:

```ruby
I18nOnSteroids::TranslationHelper.register_pipe_alias(:cut, :truncate)
```

```yaml
en:
  preview: "${text | cut: 100}"  # Same as truncate
```

### Rails Generator

Generate custom pipes with boilerplate:

```bash
rails generate i18n_pipe my_custom
rails generate i18n_pipe format --namespace=datetime
rails generate i18n_pipe humanize_bytes --description="Format bytes"
```

This creates:
- `app/pipes/my_custom_pipe.rb`
- Registers pipe in `config/initializers/i18n_on_steroids.rb`

## Configuration

Configure I18nOnSteroids in an initializer:

```ruby
# config/initializers/i18n_on_steroids.rb
I18nOnSteroids.configure do |config|
  # Default truncate length (default: 30)
  config.default_truncate_length = 50

  # Default rounding precision (default: 2)
  config.default_round_precision = 2

  # Return empty string for missing values instead of placeholder (default: false)
  config.fallback_on_missing_value = false

  # Raise error on unknown pipes (default: false)
  config.raise_on_unknown_pipe = false

  # Enable debug logging of pipe transformations (default: false)
  config.debug_mode = false

  # Strict mode: raise on all errors, not just unknown pipes (default: false)
  config.strict_mode = false
end
```

### Debug Mode

Enable debug mode to log all pipe transformations:

```ruby
I18nOnSteroids.configure do |config|
  config.debug_mode = true
end
```

Output:
```
[I18nOnSteroids] Processing translation for key: users.greeting
[I18nOnSteroids] Applying 1 pipe(s) to value: "john doe"
[I18nOnSteroids] Applying pipe 'titleize' with params: nil
[I18nOnSteroids] Result after 'titleize': "John Doe"
```

### Strict Mode

Strict mode raises errors for all pipe failures:

```ruby
I18nOnSteroids.configure do |config|
  config.strict_mode = true  # Raises on unknown pipes AND execution errors
end
```

## Interactive Console

I18nOnSteroids includes helpful console commands for development:

```bash
bin/console
```

Available commands:

```ruby
# Show interactive demo of all features
I18nOnSteroids.demo

# Test a pipe with sample input
I18nOnSteroids.test_pipe(:upcase, 'hello')
# => Input: "hello"
#    Output: "HELLO"

# List all available pipes
I18nOnSteroids.list_pipes

# Get detailed info about a specific pipe
I18nOnSteroids.pipe_info(:truncate)
```

## Performance

I18nOnSteroids is optimized for production use:

### Optimizations

- ✅ **Thread-safe** - Safe for Puma/concurrent requests
- ✅ **Pre-compiled regex** - Patterns compiled once at load time
- ✅ **Pipe cache** - Parsed pipe chains cached automatically
- ✅ **Lazy evaluation** - Skip processing when no pipes present
- ✅ **Zero allocations** - Frozen constants and efficient string handling

### Benchmarks

Run the benchmark suite:

```bash
BUNDLE_GEMFILE=gemfiles/ruby_3_plus.gemfile bundle exec ruby benchmark/performance.rb
```

Expected performance (typical hardware):
- Simple interpolations: ~100K-300K ops/sec
- Single pipe: ~50K-150K ops/sec
- Multiple pipes: ~20K-80K ops/sec
- Complex translations: ~10K-40K ops/sec

Cache hits are typically 10-50% faster than cache misses.

See [benchmark/README.md](benchmark/README.md) for details.

## Syntax Support

I18nOnSteroids supports three interpolation syntaxes:

```yaml
en:
  example:
    dollar: "${value | upcase}"      # Recommended
    percent: "%{value | upcase}"     # I18n compatible
    double: "{{value | upcase}}"     # Alternative
```

All syntaxes support the full feature set (pipes, conditions, composition).

## Mixed Content

Combine standard I18n interpolation with advanced pipes:

```yaml
en:
  items:
    summary: "Showing %{from} - %{to} of ${total | number_with_delimiter} ${item | pluralize:%{total}}"
```

```ruby
t('items.summary', from: 1, to: 10, total: 1234, item: 'item')
# => "Showing 1 - 10 of 1,234 items"
```

## Real-World Examples

### E-commerce

```yaml
en:
  products:
    price: "${amount | currency: ${locale_currency}}"
    sale: "${original | currency: ${currency}} ${discount | round: 0}% off!"
    stock: "${count | pluralize: ${unit}} ${available | default: in stock}"
```

### Admin Dashboard

```yaml
en:
  admin:
    user_info: "${name | titleize} (${email | downcase})"
    sensitive: "${data | upcase if: admin}"
    log: "${timestamp | date_format: %Y-%m-%d %H:%M} - ${message | truncate: 100}"
```

### Content Management

```yaml
en:
  posts:
    title: "${title | titleize | truncate: 60}"
    slug: "${title | parameterize}"
    summary: "${body | strip | squish | truncate: 200}"
    meta: "By ${author | titleize} on ${published_at | date_format: %B %d, %Y}"
```

### User Notifications

```yaml
en:
  notifications:
    count: "You have ${count | pluralize: ${type}}"
    amount: "${value | currency: $} ${status | default: pending}"
    time: "${duration | round: 1} ${unit | pluralize: ${duration}}"
```

## Error Handling

### Unknown Pipes

By default, unknown pipes are silently ignored:

```yaml
en:
  test: "${value | nonexistent_pipe}"
```

```ruby
t('test', value: 'hello')
# => "hello"  (pipe ignored)
```

Enable strict error handling:

```ruby
config.raise_on_unknown_pipe = true  # Raises on unknown pipes only
config.strict_mode = true            # Raises on all errors
```

### Missing Values

Missing interpolation values return placeholder by default:

```yaml
en:
  test: "${missing | upcase}"
```

```ruby
t('test')
# => "%{missing | upcase}"
```

Enable fallback mode:

```ruby
config.fallback_on_missing_value = true

t('test')
# => ""  (empty string)
```

## Development

After checking out the repo:

```bash
bin/setup              # Install dependencies
bundle exec rake test  # Run tests
bin/console            # Interactive prompt
```

To install this gem onto your local machine:

```bash
bundle exec rake install
```

### Running Tests

```bash
# With specific Ruby/Rails version
BUNDLE_GEMFILE=gemfiles/ruby_3_plus.gemfile bundle exec rake test

# With code coverage
COVERAGE=true bundle exec rake test
```

### Code Quality

```bash
bundle exec rubocop           # Lint code
bundle exec rubocop -a        # Auto-fix issues
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/games-directory/i18n_on_steroids.

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for your changes
4. Ensure tests pass (`bundle exec rake test`)
5. Ensure Rubocop passes (`bundle exec rubocop`)
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create a new Pull Request

Please make sure to update documentation and add tests before submitting.

### Project Goals

The goal is to support all ActionView::Helpers methods that make sense in a translation context, while maintaining:
- High performance
- Thread safety
- Backward compatibility
- Clean, maintainable code

## Versioning

I18nOnSteroids follows [Semantic Versioning](https://semver.org/).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the I18nOnSteroids project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/games-directory/i18n_on_steroids/blob/main/CODE_OF_CONDUCT.md).

## Credits

Developed by [Studio51 Solutions](https://github.com/games-directory).

## Support

- 📖 [Documentation](https://github.com/games-directory/i18n_on_steroids)
- 🐛 [Issue Tracker](https://github.com/games-directory/i18n_on_steroids/issues)
- 💬 [Discussions](https://github.com/games-directory/i18n_on_steroids/discussions)
