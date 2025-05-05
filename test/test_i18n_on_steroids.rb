# frozen_string_literal: true

require "test_helper"
require "yaml"

class TestI18nOnSteroids < Minitest::Test
  include ActionView::Helpers::NumberHelper
  include I18nOnSteroids::TranslationHelper

  def setup
    fixture_file = File.join(File.dirname(__FILE__), "fixtures", "en.yml")
    translations = YAML.load_file(fixture_file)

    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.store_translations(:en, translations["en"])

    I18nOnSteroids.configure do |config|
      config.default_truncate_length = 30
      config.default_round_precision = 2
      config.fallback_on_missing_value = false
      config.raise_on_unknown_pipe = false
    end

    I18nOnSteroids::TranslationHelper.register_pipe("test_pipe", lambda { |val, params, _|
      if params
        "TEST(#{val}:#{params})"
      else
        "TEST(#{val})"
      end
    })
  end

  def test_that_it_has_a_version_number
    refute_nil ::I18nOnSteroids::VERSION
  end

  def test_simple_translation
    assert_equal "Hello, John!", translate(:simple, name: "John")
  end

  def test_translation_with_pipes
    assert_equal "Count: 1,234", translate(:with_pipes, count: 1234)
  end

  def test_mixed_translation
    assert_equal "Items: 1,234 | items", translate(:mixed, count: 1234, item: "item")
  end

  def test_complex_translation
    assert_equal "Showing 1 - 10 of 1,234 items",
                 translate(:complex, from: 1, to: 10, total: 1234, item: "item")
  end

  def test_unknown_pipe
    assert_equal "Unknown: original", translate(:unknown_pipe, value: "original")
  end

  def test_missing_interpolation
    assert_equal "Missing: %{missing}", translate(:missing_interpolation)
  end

  def test_regular_string_with_pipes
    assert_equal "I'm not screaming, YOU ARE", translate(:regular_string)
  end

  def test_mixed_regular_and_interpolation
    assert_equal "Mixed: VALUE and 1,234", translate(:mixed_regular_and_interpolation, count: 1234)
  end

  def test_parameterized_pipes
    I18n.backend.store_translations(:en, {
                                      parameterized: "Length: ${value | truncate:10}"
                                    })

    assert_equal "Length: Hello W...", translate(:parameterized, value: "Hello World")
  end

  def test_registered_custom_pipe
    I18n.backend.store_translations(:en, {
                                      custom: "Custom: ${value | test_pipe}",
                                      parameterized_custom: "Custom: ${value | test_pipe:special}"
                                    })

    assert_equal "Custom: TEST(something)", translate(:custom, value: "something")
    assert_equal "Custom: TEST(something:special)", translate(:parameterized_custom, value: "something")
  end

  def test_changing_pipe_separator
    original_separator = I18nOnSteroids::TranslationHelper.pipe_separator

    begin
      I18nOnSteroids::TranslationHelper.pipe_separator = ">"

      I18n.backend.store_translations(:en, {
                                        different_separator: "Separator: ${value > upcase}"
                                      })

      assert_equal "Separator: HELLO", translate(:different_separator, value: "hello")
    ensure
      I18nOnSteroids::TranslationHelper.pipe_separator = original_separator
    end
  end

  def test_fallback_on_missing_value
    I18n.backend.store_translations(:en, {
                                      missing_value: "Missing: ${nonexistent | upcase}"
                                    })

    assert_equal "Missing: ${nonexistent | upcase}", translate(:missing_value)

    original_fallback = I18nOnSteroids.configuration.fallback_on_missing_value

    begin
      I18nOnSteroids.configuration.fallback_on_missing_value = true
      assert_equal "Missing: ", translate(:missing_value)
    ensure
      I18nOnSteroids.configuration.fallback_on_missing_value = original_fallback
    end
  end

  def test_raise_on_unknown_pipe
    I18n.backend.store_translations(:en, {
                                      unknown_pipe_test: "Unknown: ${value | nonexistent_pipe}"
                                    })

    assert_equal "Unknown: original", translate(:unknown_pipe_test, value: "original")

    original_raise_setting = I18nOnSteroids.configuration.raise_on_unknown_pipe

    begin
      I18nOnSteroids.configuration.raise_on_unknown_pipe = true
      assert_raises(RuntimeError) do
        translate(:unknown_pipe_test, value: "original")
      end
    ensure
      I18nOnSteroids.configuration.raise_on_unknown_pipe = original_raise_setting
    end
  end

  def test_default_settings_for_pipes
    I18n.backend.store_translations(:en, {
                                      default_truncate: "Truncated: ${value | truncate}",
                                      default_round: "Rounded: ${value | round}"
                                    })

    assert_equal "Truncated: Something very very very ve...",
                 translate(:default_truncate, value: "Something very very very very long")

    assert_equal "Rounded: 3.14",
                 translate(:default_round, value: 3.14159)

    original_truncate = I18nOnSteroids.configuration.default_truncate_length
    original_round = I18nOnSteroids.configuration.default_round_precision

    begin
      I18nOnSteroids.configuration.default_truncate_length = 10
      I18nOnSteroids.configuration.default_round_precision = 4

      assert_equal "Truncated: Somethi...",
                   translate(:default_truncate, value: "Something very very long")
      assert_equal "Rounded: 3.1416",
                   translate(:default_round, value: 3.14159)
    ensure
      I18nOnSteroids.configuration.default_truncate_length = original_truncate
      I18nOnSteroids.configuration.default_round_precision = original_round
    end
  end

  def test_different_interpolation_patterns
    I18n.backend.store_translations(:en, {
                                      custom_pattern: "Custom: {{value | upcase}}"
                                    })

    assert_equal "Custom: HELLO", translate(:custom_pattern, value: "hello")
  end
end
