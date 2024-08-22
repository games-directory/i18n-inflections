# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "active_support"
require "action_view"
require "i18n_on_steroids"

class TestI18nBackend < I18n::Backend::Simple
  def initialize(translations)
    super()
    store_translations(:en, translations)
  end
end