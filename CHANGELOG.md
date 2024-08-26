## [Unreleased]

- Rename the gem to `i18n-inflections` to better reflect its purpose.
- Tidy up the code and extract the `Inflector` helpers into their own module.
- Add more tests to cover the new functionality.
- Add more examples to the README.

## [0.1.1] - 2024-08-21

- Added ability to pipe regular strings. Because, why not?
  `${ 'Hello, World!' | upcase } => HELLO, WORLD!`
Note: This needs to be done via `${}` instead of `%{}` otherwise Psych will throw an error.
- Started listening to `rubocop-performance` and apparently improved some performance.
- Enabled more `rubocop` cops.
- Lowered 'ActiveSupport' and 'ActionView' version requirements to allow more Ruby versions to be supported. 

## [0.1.0] - 2024-08-22

- Initial release

[//]: # (# MAJOR version when you make incompatible API changes)
[//]: # (# MINOR version when you add functionality in a backward compatible manner)
[//]: # (# PATCH version when you make backward compatible bug fixes)
