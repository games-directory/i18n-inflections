# frozen_string_literal: true

module I18nInflections
  module Translate
    include I18nInflections::Helper::Base

    def translate(key, **options)
      translation = if defined?(super)
                      super(key, **options)
                    else
                      I18n.translate(key, **options)
                    end

      return process_mixed_translation(translation, options) if translation.is_a?(String) && (translation.include?("%{") || translation.include?("${"))

      translation
    end
    alias t translate

  end
end
