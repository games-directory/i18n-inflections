# I18nOnSteroids

I18nOnSteroids is a Ruby gem that enhances Rails' I18n functionality with advanced interpolation and piping features. It allows you to use more complex translation patterns directly in your locale files, reducing the need for view-specific formatting logic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'i18n_on_steroids'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install i18n_on_steroids
```

## Usage

Once installed, I18nOnSteroids automatically enhances your Rails I18n functionality. You can use the following advanced features in your locale files:

### Advanced Interpolation

Use `${}` for advanced interpolation with pipes:

```yaml
en:
  users:
    count: "There are ${count | number_with_delimiter} users"
```

In your view:

```ruby
<%= t('users.count', count: 1000) %>
# Output: "There are 1,000 users"
```

### Available Pipes
The goal is to support all the ActionView::Helpers methods that make sense in a translation context.
The following pipes are currently available:

- `number_with_delimiter`: Formats numbers with thousands separators
- `pluralize`: Pluralizes a word
- `upcase`: Converts text to uppercase
- `downcase`: Converts text to lowercase
- `capitalize`: Capitalizes the first character
- `html_safe`: Marks the string as HTML safe
- `format:...`: Applies a format string to the value

### Mixed Content

You can mix regular interpolation `%{}` with advanced interpolation `${}`:

```yaml
en:
  items:
    summary: "Showing %{from} - %{to} of ${total | number_with_delimiter} ${item | pluralize:%{total}}"
```

In your view:

```ruby
<%= t('items.summary', from: 1, to: 10, total: 1234, item: 'item') %>
# Output: "Showing 1 - 10 of 1,234 items"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/games-directory/i18n_on_steroids. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/games-directory/i18n_on_steroids/blob/main/CODE_OF_CONDUCT.md).

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Please make sure to update/add any relevant tests and documentation before submitting your pull request. Also, `bundle exec rake` must pass without any failures.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the I18nOnSteroids project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/games-directory/i18n_on_steroids/blob/main/CODE_OF_CONDUCT.md).