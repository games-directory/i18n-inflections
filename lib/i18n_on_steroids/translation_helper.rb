module I18nOnSteroids
  module TranslationHelper
    def translate(key, **options)
      translation = if defined?(super)
                      super(key, **options)
                    else
                      I18n.translate(key, **options)
                    end

      if translation.is_a?(String) && (translation.include?('%{') || translation.include?('${'))
        process_mixed_translation(translation, options)
      else
        translation
      end
    end
    alias :t :translate

    private

    def process_mixed_translation(translation, options)
      parts = translation.split(/(%\{[^}]+\}|\$\{[^}]+\})/)
      processed_parts = parts.map do |part|
        if part.start_with?('%{') || part.start_with?('${')
          process_interpolation(part, options)
        else
          part
        end
      end
      processed_parts.join.html_safe
    end

    def process_interpolation(interpolation, options)
      match_data = interpolation.match(/^(%\{|\$\{)([^}]+)\}$/)
      return interpolation unless match_data

      key, *pipes = match_data[2].split('|').map(&:strip)
      value = options[key.to_sym]

      if value.nil?
        interpolation
      else
        apply_pipes(value, pipes, options)
      end
    end

    def apply_pipes(value, pipes, options)
      pipes.reduce(value) do |result, pipe|
        case pipe
        when 'number_with_delimiter'
          number_with_delimiter(result)
        when 'pluralize'
          result.pluralize
        when /^pluralize(?::(\d+))?$/
          count = $1 ? $1.to_i : options[:count]
          count ? result.pluralize(count) : result.pluralize
        when 'upcase'
          result.upcase
        when 'downcase'
          result.downcase
        when 'capitalize'
          result.capitalize
        when 'html_safe'
          result.html_safe
        when /^format:(.+)$/
          format($1, result)
        else
          # You might want to raise an error for unknown pipes
          result
        end
      end
    end
  end
end