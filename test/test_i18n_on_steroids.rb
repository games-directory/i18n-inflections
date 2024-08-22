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
end
