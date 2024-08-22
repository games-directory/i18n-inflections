# frozen_string_literal: true

require "test_helper"

class TestI18nOnSteroids < Minitest::Test
  include ActionView::Helpers::NumberHelper
  include I18nOnSteroids::TranslationHelper

  def setup
    @translations = {
      simple: "Hello, %<name>s!",
      with_pipes: "Count: ${count | number_with_delimiter}",
      mixed: "Items: %{count | number_with_delimiter} | ${item | pluralize}",
      complex: "Showing %<from>s - %<to>s of %{total | number_with_delimiter} ${item | pluralize:%<total>s}",
      unknown_pipe: "Unknown: ${value | unknown_pipe}",
      missing_interpolation: "Missing: %<missing>s"
    }
    I18n.backend = TestI18nBackend.new(@translations)
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
    assert_equal "Missing: %<missing>s", translate(:missing_interpolation)
  end
end
