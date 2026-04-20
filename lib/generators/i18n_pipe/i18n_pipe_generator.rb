# frozen_string_literal: true

require "rails/generators"

class I18nPipeGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  class_option :namespace, type: :string, default: nil, desc: "Namespace for the pipe (e.g., datetime, money)"
  class_option :description, type: :string, default: "Custom pipe", desc: "Description of what the pipe does"

  def create_pipe_file
    template "pipe.rb.tt", File.join("app/pipes", class_path, "#{file_name}_pipe.rb")
  end

  def create_initializer
    return if File.exist?("config/initializers/i18n_on_steroids.rb")

    create_file "config/initializers/i18n_on_steroids.rb", <<~RUBY
      # frozen_string_literal: true

      # I18nOnSteroids configuration
      I18nOnSteroids.configure do |config|
        # Default truncate length
        # config.default_truncate_length = 30

        # Default round precision
        # config.default_round_precision = 2

        # Fallback on missing values
        # config.fallback_on_missing_value = false

        # Raise on unknown pipes
        # config.raise_on_unknown_pipe = false

        # Enable debug mode (logs pipe transformations)
        # config.debug_mode = false

        # Enable strict mode (raises on all errors)
        # config.strict_mode = false
      end

      # Register custom pipes
      # I18nOnSteroids::TranslationHelper.register_pipe(:my_pipe, ->(value, params, options) {
      #   # Your transformation logic here
      #   value
      # })
    RUBY
  end

  def add_pipe_registration
    registration_code = if options[:namespace]
                          "  I18nOnSteroids::TranslationHelper.register_pipe(:#{file_name}, #{class_name}Pipe.new, namespace: :#{options[:namespace]})"
                        else
                          "  I18nOnSteroids::TranslationHelper.register_pipe(:#{file_name}, #{class_name}Pipe.new)"
                        end

    inject_into_file "config/initializers/i18n_on_steroids.rb",
                     after: "# Register custom pipes\n" do
      "#{registration_code}\n"
    end
  end

  private

  def pipe_namespace
    options[:namespace]
  end

  def pipe_description
    options[:description]
  end
end
