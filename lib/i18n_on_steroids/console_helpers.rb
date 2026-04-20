# frozen_string_literal: true

module I18nOnSteroids
  module ConsoleHelpers
    def self.demo
      puts "\n#{"=" * 80}"
      puts "I18nOnSteroids Interactive Demo"
      puts "=" * 80

      # Setup demo translations
      I18n.backend.store_translations(:en, {
                                        demo: {
                                          simple: "Hello ${name | upcase}!",
                                          chained: "${text | titleize | truncate: 20}",
                                          conditional: "${value | upcase if: admin}",
                                          composition: "${count | pluralize: ${unit}}",
                                          formatting: "${price | currency: €} on ${date | date_format: %B %d, %Y}"
                                        }
                                      })

      include TranslationHelper

      puts "\n📝 Demo Translations:"
      puts "-" * 80

      demos = [
        {
          key: "demo.simple",
          opts: { name: "world" },
          desc: "Basic pipe transformation"
        },
        {
          key: "demo.chained",
          opts: { text: "hello world from ruby" },
          desc: "Chained pipes"
        },
        {
          key: "demo.conditional",
          opts: { value: "secret", admin: true },
          desc: "Conditional pipe (admin=true)"
        },
        {
          key: "demo.conditional",
          opts: { value: "secret", admin: false },
          desc: "Conditional pipe (admin=false)"
        },
        {
          key: "demo.composition",
          opts: { count: 5, unit: "item" },
          desc: "Pipe composition"
        },
        {
          key: "demo.formatting",
          opts: { price: 1234.56, date: Time.now },
          desc: "Complex formatting"
        }
      ]

      demos.each_with_index do |demo, idx|
        puts "\n#{idx + 1}. #{demo[:desc]}"
        puts "   Key: #{demo[:key]}"
        puts "   Options: #{demo[:opts].inspect}"
        puts "   Result: #{translate(demo[:key].to_sym, **demo[:opts])}"
      end

      puts "\n#{"=" * 80}"
      puts "Available Commands:"
      puts "  I18nOnSteroids.demo              # Show this demo"
      puts "  I18nOnSteroids.test_pipe         # Test a pipe interactively"
      puts "  I18nOnSteroids.list_pipes        # List all available pipes"
      puts "  I18nOnSteroids.pipe_info(name)   # Show info about a pipe"
      puts "#{"=" * 80}\n"
    end

    def self.test_pipe(pipe_name = nil, value = nil)
      include TranslationHelper

      if pipe_name.nil?
        puts "\nUsage: I18nOnSteroids.test_pipe(:pipe_name, value, param: 'optional')"
        puts "\nExample:"
        puts "  I18nOnSteroids.test_pipe(:upcase, 'hello')"
        puts "  I18nOnSteroids.test_pipe(:truncate, 'long text', '10')"
        puts "  I18nOnSteroids.test_pipe(:currency, 1234.56, '€')"
        return
      end

      if value.nil?
        puts "Error: Please provide a value to test"
        return
      end

      puts "\n🧪 Testing Pipe: #{pipe_name}"
      puts "-" * 80

      I18n.backend.store_translations(:en, {
                                        test: "Result: ${value | #{pipe_name}}"
                                      })

      begin
        result = translate(:test, value: value)
        puts "Input:  #{value.inspect}"
        puts "Output: #{result}"
        puts "✓ Success"
      rescue StandardError => e
        puts "✗ Error: #{e.message}"
      end

      puts
    end

    def self.list_pipes
      pipes = TranslationHelper.available_pipes
      aliases = TranslationHelper.pipe_aliases

      puts "\n📋 Available Pipes"
      puts "=" * 80

      puts "\n✨ Built-in Pipes (#{pipes[:built_in].length}):"
      pipes[:built_in].sort.each do |pipe|
        puts "  • #{pipe}"
      end

      if pipes[:custom].any?
        puts "\n🔧 Custom Pipes (#{pipes[:custom].length}):"
        pipes[:custom].sort.each do |pipe|
          puts "  • #{pipe}"
        end
      end

      if aliases.any?
        puts "\n🔗 Pipe Aliases (#{aliases.length}):"
        aliases.sort.each do |alias_name, target|
          puts "  • #{alias_name} → #{target}"
        end
      end

      puts "\n💡 Tip: Use I18nOnSteroids.pipe_info(:pipe_name) for details"
      puts "#{"=" * 80}\n"
    end

    def self.pipe_info(pipe_name)
      pipe_docs = {
        upcase: "Convert string to uppercase",
        downcase: "Convert string to lowercase",
        capitalize: "Capitalize first character",
        titleize: "Convert to title case",
        humanize: "Make string human-readable",
        parameterize: "Convert to URL-safe format (params: separator)",
        strip: "Remove leading/trailing whitespace",
        squish: "Remove excess whitespace",
        truncate: "Truncate to length (params: length)",
        pluralize: "Pluralize word (params: count)",
        round: "Round number (params: precision)",
        number_with_delimiter: "Format number with thousands separator",
        currency: "Format as currency (params: unit)",
        date_format: "Format date (params: strftime pattern)",
        time_format: "Format time (params: strftime pattern)",
        default: "Provide fallback value (params: default value)",
        format: "Custom format string (params: format)",
        html_safe: "Mark string as HTML safe"
      }

      puts "\n📖 Pipe Info: #{pipe_name}"
      puts "=" * 80

      doc = pipe_docs[pipe_name.to_sym]
      if doc
        puts "\nDescription: #{doc}"

        examples = {
          upcase: "\${name | upcase}",
          downcase: "\${NAME | downcase}",
          capitalize: "\${text | capitalize}",
          titleize: "\${text | titleize}",
          humanize: "\${field_name | humanize}",
          parameterize: "\${title | parameterize} or \${title | parameterize: _}",
          strip: "\${text | strip}",
          squish: "\${text | squish}",
          truncate: "\${text | truncate: 50}",
          pluralize: "\${word | pluralize: %{count}}",
          round: "\${number | round: 2}",
          currency: "\${price | currency} or \${price | currency: €}",
          date_format: "\${date | date_format: %Y-%m-%d}",
          time_format: "\${time | time_format: %H:%M}",
          default: "\${optional | default: N/A}",
          format: "\${value | format: %.2f}"
        }

        puts "\nExample: #{examples[pipe_name.to_sym]}" if examples[pipe_name.to_sym]

        # Check for aliases
        aliases = TranslationHelper.pipe_aliases.select { |_, target| target == pipe_name.to_s }
        puts "\nAliases: #{aliases.keys.join(", ")}" if aliases.any?

      else
        puts "\nNo documentation available for '#{pipe_name}'"
        puts "\nUse I18nOnSteroids.list_pipes to see all available pipes"
      end

      puts "#{"=" * 80}\n"
    end
  end

  # Convenience methods at module level
  def self.demo
    ConsoleHelpers.demo
  end

  def self.test_pipe(*args)
    ConsoleHelpers.test_pipe(*args)
  end

  def self.list_pipes
    ConsoleHelpers.list_pipes
  end

  def self.pipe_info(name)
    ConsoleHelpers.pipe_info(name)
  end
end
