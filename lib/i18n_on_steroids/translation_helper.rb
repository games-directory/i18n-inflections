# frozen_string_literal: true

module I18nOnSteroids
  module TranslationHelper
    def translate(key, **options)
      translation = if defined?(super)
                      super(key, **options)
                    else
                      I18n.translate(key, **options)
                    end

      if translation.is_a?(String) && (translation.include?("%{") || translation.include?("${"))
        process_mixed_translation(translation, options)
      else
        translation
      end
    end
    alias t translate

    private

    def process_mixed_translation(translation, options)
      parts = translation.split(/(\$\{[^}]+\}|%\{[^}]+\})/)
      processed_parts = parts.map do |part|
        if part.start_with?("${", "%{")
          process_interpolation(part, options)
        else
          part
        end
      end

      processed_parts.join
    end

    def process_interpolation(interpolation, options)
      match_data = interpolation.match(/^(\$\{|%\{)([^}]+)}$/)

      return interpolation unless match_data

      if (content = match_data[2].strip).start_with?("'", '"')
        # This is a regular string with pipes: ${'Hello' | upcase}
        process_string_with_pipes(content)
      else
        # This is a variable interpolation with pipes: ${name | upcase}
        key, *pipes = content.split("|").map(&:strip)
        value = options[key.to_sym]

        return interpolation if value.nil?

        apply_pipes(value, pipes, options)
      end
    end

    def process_string_with_pipes(content)
      string, *pipes = content.split("|").map(&:strip)
      string = string[1...-1] if string.start_with?('"', "'")

      apply_pipes(string, pipes, {})
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def apply_pipes(value, pipes, options)
      pipes.reduce(value) do |result, pipe|
        case pipe
        when "number_with_delimiter"
          number_with_delimiter(result)
        when "pluralize"
          result.pluralize
        when /^pluralize(?::(\d+))?$/
          count = ::Regexp.last_match(1) ? ::Regexp.last_match(1).to_i : options[:count]
          count ? result.pluralize(count) : result.pluralize
        when "upcase"
          result.upcase
        when "downcase"
          result.downcase
        when "capitalize"
          result.capitalize
        when "html_safe"
          result.html_safe
        when /^format:(.+)$/
          format(::Regexp.last_match(1), result)
        else
          # You might want to raise an error for unknown pipes
          result
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
