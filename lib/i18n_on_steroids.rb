# frozen_string_literal: true

require "i18n_on_steroids/version"
require "i18n_on_steroids/translation_helper"

module I18nOnSteroids
  class Error < StandardError; end

  if defined?(Rails)
    class Railtie < Rails::Railtie
      initializer "i18n_on_steroids.configure_rails_initialization" do
        ActiveSupport.on_load(:action_view) do
          include I18nOnSteroids::TranslationHelper
        end
      end
    end
  end
end
