# frozen_string_literal: true

require_relative "lib/i18n_on_steroids/version"

Gem::Specification.new do |spec|
  spec.name = "i18n_on_steroids"
  spec.version = I18nOnSteroids::VERSION
  spec.authors = ["pacMakaveli"]
  spec.email = ["oss@studio51.solutions"]

  spec.summary = "A gem that provides advanced interpolation and piping features for Rails I18n"
  spec.description = "A Ruby gem that enhances I18n functionality with advanced interpolation and piping features"
  spec.homepage = "https://github.com/games-directory/i18n_on_steroids"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.1')
    spec.add_dependency "activesupport", "~> 6.1.0"
    spec.add_dependency "actionview", "~> 6.1.0"
  elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.2')
    spec.add_dependency "activesupport", "~> 7.0.0"
    spec.add_dependency "actionview", "~> 7.0.0"
  else
    spec.add_dependency "activesupport", "~> 7.1", ">= 6.1", "< 8"
    spec.add_dependency "actionview", "~> 7.1", ">= 6.1", "< 8"
  end

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/games-directory/i18n_on_steroids"
  spec.metadata["changelog_uri"] = "https://github.com/games-directory/i18n_on_steroids/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end
