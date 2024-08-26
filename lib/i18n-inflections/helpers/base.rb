# frozen_string_literal: true

module I18nInflections
  module Helper
    module Base

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

      def apply_pipes(value, pipes, options)
        pipes.reduce(value) do |result, pipe|
          safe_send(pipe, result, options)
        end
      end

      def number_with_delimiter(result)
        number_with_delimiter(result)
      end

      def pluralize(result)
        result.pluralize
        # /^pluralize(?::(\d+))?$/
        # count = ::Regexp.last_match(1) ? ::Regexp.last_match(1).to_i : options[:count]
        # count ? result.pluralize(count) : result.pluralize
      end

      def upcase(result)
        result.upcase
      end

      def downcase(result)
        result.downcase
      end

      def capitalize(result)
        result.capitalize
      end

      def html_safe(result)
        result.html_safe
      end

      def format(format, result)
        case format
        when "currency"
          number_to_currency(result)
        when "percentage"
          number_to_percentage(result)
        else
          result
        end

        format(::Regexp.last_match(1), result)
      end
    end
  end
end
