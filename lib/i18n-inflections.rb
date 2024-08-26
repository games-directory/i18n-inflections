# frozen_string_literal: true

require "i18n-inflections/version"
require "i18n-inflections/translate"

module I18nInflections
  class Error < StandardError; end

  if defined?(Rails)
    class Railtie < Rails::Railtie
      initializer "i18n-inflections.configure_rails_initialization" do
        ActiveSupport.on_load(:action_view) do
          include I18nInflections::Translate
        end
      end
    end
  end
end
