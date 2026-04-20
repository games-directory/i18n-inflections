# frozen_string_literal: true

module I18nOnSteroids
  class Configuration
    attr_accessor :default_truncate_length,
                  :default_round_precision,
                  :fallback_on_missing_value,
                  :raise_on_unknown_pipe,
                  :debug_mode,
                  :strict_mode

    def initialize
      @default_truncate_length = 30
      @default_round_precision = 2
      @fallback_on_missing_value = false
      @raise_on_unknown_pipe = false
      @debug_mode = false
      @strict_mode = false
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  module TranslationHelper
    # Pre-compiled regex patterns for better performance
    INTERPOLATION_SPLIT_PATTERN = /(\$\{[^}]+\}|%\{[^}]+\}|\{\{[^}]+\}\})/.freeze
    DOLLAR_BRACE_PATTERN = /^\$\{([^}]+)\}$/.freeze
    PERCENT_BRACE_PATTERN = /^%\{([^}]+)\}$/.freeze
    DOUBLE_BRACE_PATTERN = /^\{\{([^}]+)\}\}$/.freeze
    PARAM_INTERPOLATION_PATTERN = /^%\{([^}]+)\}$/.freeze

    class << self
      def custom_pipes
        @custom_pipes ||= {}
      end

      def pipe_aliases
        @pipe_aliases ||= {
          "trim" => "truncate",
          "limit" => "truncate",
          "shorten" => "truncate"
        }
      end

      def pipe_separator
        @pipe_separator ||= "|"
      end

      def pipe_separator=(separator)
        @pipe_separator = separator
        clear_pipe_cache! # Clear cache when separator changes
      end

      def pipe_cache
        @pipe_cache ||= {}
      end

      def clear_pipe_cache!
        @pipe_cache = {}
      end

      def register_pipe(name, callable, namespace: nil)
        pipe_key = namespace ? "#{namespace}.#{name}" : name.to_s
        custom_pipes[pipe_key] = callable
        clear_pipe_cache! # Clear cache when pipes are registered
      end

      def register_pipe_alias(alias_name, pipe_name)
        pipe_aliases[alias_name.to_s] = pipe_name.to_s
        clear_pipe_cache! # Clear cache when aliases are registered
      end

      def resolve_pipe_name(name)
        pipe_aliases[name.to_s] || name.to_s
      end

      def available_pipes
        built_in = %w[
          number_with_delimiter pluralize truncate round upcase downcase capitalize html_safe format
          titleize humanize parameterize strip squish
          currency date_format time_format default
        ]
        custom = custom_pipes.keys

        {
          built_in: built_in,
          custom: custom
        }
      end
    end

    def translate(key, **options)
      translation = if defined?(super)
                      super(key, **options)
                    else
                      I18n.translate(key, **options)
                    end

      if translation.is_a?(String) && (translation.include?("%{") || translation.include?("${") || translation.include?("{{"))
        debug_log "Processing translation for key: #{key}"
        process_mixed_translation(translation, options)
      else
        translation
      end
    end
    alias t translate

    private

    def debug_log(message)
      return unless I18nOnSteroids.configuration.debug_mode

      if defined?(Rails) && Rails.logger
        Rails.logger.debug("[I18nOnSteroids] #{message}")
      else
        puts "[I18nOnSteroids DEBUG] #{message}"
      end
    end

    def process_mixed_translation(translation, options)
      parts = translation.split(INTERPOLATION_SPLIT_PATTERN)
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
        match_data = interpolation.match(DOLLAR_BRACE_PATTERN)
        return interpolation unless match_data

        content = match_data[1].strip
        process_content_with_pipes(content, options)
      elsif interpolation.start_with?("%{")
        match_data = interpolation.match(PERCENT_BRACE_PATTERN)
        return interpolation unless match_data

        content = match_data[1].strip
        process_content_with_pipes(content, options)
      elsif interpolation.start_with?("{{")
        match_data = interpolation.match(DOUBLE_BRACE_PATTERN)
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
      # Create cache key from pipe segments and separator
      cache_key = "#{pipe_segments.join('|')}:#{TranslationHelper.pipe_separator}"

      # Return cached result if available
      TranslationHelper.pipe_cache[cache_key] ||= begin
        pipe_segments.map do |segment|
          # Extract conditional (if/unless) if present
          condition_type = nil
          condition_key = nil

          if segment.include?(" if:")
            parts = segment.split(" if:", 2)
            segment = parts[0]
            condition_type = :if
            condition_key = parts[1]&.strip
          elsif segment.include?(" unless:")
            parts = segment.split(" unless:", 2)
            segment = parts[0]
            condition_type = :unless
            condition_key = parts[1]&.strip
          end

          # Parse pipe name and parameters
          pipe_parts = segment.split(":", 2)
          name = pipe_parts[0].strip
          params = pipe_parts[1]&.strip

          pipe_info = { name: name, params: params }

          # Add condition info if present
          if condition_type
            pipe_info[:condition_type] = condition_type
            pipe_info[:condition_key] = condition_key
          end

          pipe_info
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
      # Lazy evaluation: return immediately if no pipes to apply
      return value if pipes.empty?

      debug_log "Applying #{pipes.length} pipe(s) to value: #{value.inspect}"

      pipes.reduce(value) do |result, pipe|
        pipe_name = TranslationHelper.resolve_pipe_name(pipe[:name])
        pipe_params = pipe[:params]

        # Check conditional execution
        if pipe[:condition_type]
          should_apply = evaluate_condition(pipe[:condition_type], pipe[:condition_key], options)
          unless should_apply
            debug_log "Skipping pipe '#{pipe_name}' due to failed condition"
            next result
          end
        end

        debug_log "Applying pipe '#{pipe_name}' with params: #{pipe_params.inspect}"

        begin
          transformed = if TranslationHelper.custom_pipes.key?(pipe_name)
                          TranslationHelper.custom_pipes[pipe_name].call(result, pipe_params, options)
                        else
                          case pipe_name
                          when "number_with_delimiter"
                            number_with_delimiter(result)
                          when "pluralize"
                            if pipe_params
                              if pipe_params.start_with?("%{")
                                count_key = pipe_params.match(PARAM_INTERPOLATION_PATTERN)[1]
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
                          when "titleize"
                            result.to_s.titleize
                          when "humanize"
                            result.to_s.humanize
                          when "parameterize"
                            separator = pipe_params || "-"
                            result.to_s.parameterize(separator: separator)
                          when "strip"
                            result.to_s.strip
                          when "squish"
                            result.to_s.squish
                          when "currency"
                            unit = pipe_params || "$"
                            if defined?(ActionView::Helpers::NumberHelper) && respond_to?(:number_to_currency)
                              number_to_currency(result, unit: unit)
                            else
                              "#{unit}#{number_with_delimiter(result)}"
                            end
                          when "date_format"
                            format_str = pipe_params || "%Y-%m-%d"
                            if result.respond_to?(:strftime)
                              result.strftime(format_str)
                            elsif result.is_a?(String)
                              begin
                                Date.parse(result).strftime(format_str)
                              rescue ArgumentError
                                result
                              end
                            else
                              result.to_s
                            end
                          when "time_format"
                            format_str = pipe_params || "%H:%M:%S"
                            if result.respond_to?(:strftime)
                              result.strftime(format_str)
                            elsif result.is_a?(String)
                              begin
                                Time.parse(result).strftime(format_str)
                              rescue ArgumentError
                                result
                              end
                            else
                              result.to_s
                            end
                          when "default"
                            if result.nil? || (result.respond_to?(:empty?) && result.empty?)
                              pipe_params || ""
                            else
                              result
                            end
                          else
                            handle_unknown_pipe(pipe_name, result)
                          end
                        end

          debug_log "Result after '#{pipe_name}': #{transformed.inspect}"
          transformed
        rescue StandardError => e
          # Re-raise if it's an intentional error from handle_unknown_pipe
          raise if e.message.start_with?("Unknown pipe") || e.message.start_with?("Error applying pipe")

          handle_pipe_error(pipe_name, e, result)
        end
      end
    end

    def evaluate_condition(condition_type, condition_key, options)
      condition_value = options[condition_key.to_sym]

      case condition_type
      when :if
        !!condition_value # Truthy check
      when :unless
        !condition_value # Falsy check
      else
        true # No condition or unknown type
      end
    end

    def handle_unknown_pipe(pipe_name, result)
      config = I18nOnSteroids.configuration
      should_raise = config.strict_mode || config.raise_on_unknown_pipe

      if should_raise
        available = TranslationHelper.available_pipes
        all_pipes = available[:built_in] + available[:custom]
        raise "Unknown pipe ':#{pipe_name}'. Available pipes: #{all_pipes.join(', ')}"
      end

      debug_log "Unknown pipe '#{pipe_name}' ignored, returning original value"
      result
    end

    def handle_pipe_error(pipe_name, error, result)
      config = I18nOnSteroids.configuration

      if config.strict_mode
        raise "Error applying pipe ':#{pipe_name}': #{error.message}"
      end

      debug_log "Error in pipe '#{pipe_name}': #{error.message}, returning original value"
      result
    end
  end
end
