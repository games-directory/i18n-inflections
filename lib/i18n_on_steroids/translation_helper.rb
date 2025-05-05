# frozen_string_literal: true

module I18nOnSteroids
  class Configuration
    attr_accessor :default_truncate_length,
                  :default_round_precision,
                  :fallback_on_missing_value,
                  :raise_on_unknown_pipe

    def initialize
      @default_truncate_length = 30
      @default_round_precision = 2
      @fallback_on_missing_value = false
      @raise_on_unknown_pipe = false
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  module TranslationHelper
    @@custom_pipes = {}
    @@pipe_separator = "|"

    def self.register_pipe(name, callable)
      @@custom_pipes[name.to_s] = callable
    end

    def self.pipe_separator=(separator)
      @@pipe_separator = separator
    end

    def self.pipe_separator
      @@pipe_separator
    end

    def self.available_pipes
      built_in = %w[number_with_delimiter pluralize truncate round upcase downcase capitalize html_safe format]
      custom = @@custom_pipes.keys

      {
        built_in: built_in,
        custom: custom
      }
    end

    def translate(key, **options)
      translation = if defined?(super)
                      super(key, **options)
                    else
                      I18n.translate(key, **options)
                    end

      if translation.is_a?(String) && (translation.include?("%{") || translation.include?("${") || translation.include?("{{"))
        process_mixed_translation(translation, options)
      else
        translation
      end
    end
    alias t translate

    private

    def process_mixed_translation(translation, options)
      parts = translation.split(/(\$\{[^}]+\}|%\{[^}]+\}|\{\{[^}]+\}\})/)
      processed_parts = parts.map do |part|
        if part.start_with?("${", "%{", "{{")
          process_interpolation(part, options)
        else
          part
        end
      end

      processed_parts.join
    end

    def process_interpolation(interpolation, options)
      if interpolation.start_with?("${")
        match_data = interpolation.match(/^\$\{([^}]+)\}$/)
        return interpolation unless match_data

        content = match_data[1].strip
        process_content_with_pipes(content, options)
      elsif interpolation.start_with?("%{")
        match_data = interpolation.match(/^%\{([^}]+)\}$/)
        return interpolation unless match_data

        content = match_data[1].strip
        process_content_with_pipes(content, options)
      elsif interpolation.start_with?("{{")
        match_data = interpolation.match(/^\{\{([^}]+)\}\}$/)
        return interpolation unless match_data

        content = match_data[1].strip
        process_content_with_pipes(content, options)
      else
        interpolation
      end
    end

    def process_content_with_pipes(content, options)
      separator = TranslationHelper.pipe_separator

      if content.include?(separator)
        if content.start_with?("'", '"')
          process_string_with_pipes(content)
        else
          process_variable_with_pipes(content, options)
        end
      else
        value = options[content.to_sym]
        value.nil? ? "%{#{content}}" : value.to_s
      end
    end

    def process_variable_with_pipes(content, options)
      separator = TranslationHelper.pipe_separator
      segments = content.split(separator).map(&:strip)
      key = segments.shift
      value = options[key.to_sym]

      if value.nil?
        return I18nOnSteroids.configuration.fallback_on_missing_value ? "" : "%{#{content}}"
      end

      pipes = parse_pipes(segments)
      apply_pipes(value, pipes, options)
    end

    def parse_pipes(pipe_segments)
      pipe_segments.map do |segment|
        pipe_parts = segment.split(":", 2)
        name = pipe_parts[0].strip
        params = pipe_parts[1]&.strip

        if params
          { name: name, params: params }
        else
          { name: name, params: nil }
        end
      end
    end

    def process_string_with_pipes(content)
      separator = TranslationHelper.pipe_separator
      segments = content.split(separator).map(&:strip)
      string = segments.shift
      string = string[1...-1] if string.start_with?('"', "'")

      pipes = parse_pipes(segments)
      apply_pipes(string, pipes, {})
    end

    def apply_pipes(value, pipes, options)
      pipes.reduce(value) do |result, pipe|
        pipe_name = pipe[:name]
        pipe_params = pipe[:params]

        if @@custom_pipes.key?(pipe_name)
          @@custom_pipes[pipe_name].call(result, pipe_params, options)
        else
          case pipe_name
          when "number_with_delimiter"
            number_with_delimiter(result)
          when "pluralize"
            if pipe_params
              if pipe_params.start_with?("%{")
                count_key = pipe_params.match(/^%\{([^}]+)\}$/)[1]
                count = options[count_key.to_sym]
                result.pluralize(count)
              else
                result.pluralize(pipe_params.to_i)
              end
            else
              count = options[:count]
              count ? result.pluralize(count) : result.pluralize
            end
          when "truncate"
            length = pipe_params ? pipe_params.to_i : I18nOnSteroids.configuration.default_truncate_length
            result.to_s.truncate(length)
          when "round"
            precision = pipe_params ? pipe_params.to_i : I18nOnSteroids.configuration.default_round_precision
            result.to_f.round(precision)
          when "upcase"
            result.upcase
          when "downcase"
            result.downcase
          when "capitalize"
            result.capitalize
          when "html_safe"
            result.html_safe
          when "format"
            format_str = pipe_params || "%s"
            format(format_str, result)
          else
            raise "Unknown pipe: #{pipe_name}" if I18nOnSteroids.configuration.raise_on_unknown_pipe

            result
          end
        end
      end
    end
  end
end
