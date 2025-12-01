# frozen_string_literal: true

require 'dry/cli'
require_relative 'generator'

module ClaudePluginScaffold
  module CLI
    extend Dry::CLI::Registry

    class Version < Dry::CLI::Command
      desc 'Print version'

      def call(*)
        puts ClaudePluginScaffold::VERSION
      end
    end

    class New < Dry::CLI::Command
      desc 'Create a new Claude Code plugin (includes all components by default)'

      argument :name, required: true, desc: 'Plugin name (kebab-case)'

      option :plugins, type: :integer, default: 1, desc: 'Number of plugins to create (for multi-plugin marketplaces)'
      option :minimal, type: :boolean, default: false, desc: 'Create minimal plugin (manifests only)'
      option :hooks, type: :boolean, default: nil, desc: 'Include hooks boilerplate'
      option :commands, type: :boolean, default: nil, desc: 'Include commands directory'
      option :agents, type: :boolean, default: nil, desc: 'Include agents directory'
      option :skills, type: :boolean, default: nil, desc: 'Include skills directory'
      option :mcp, type: :boolean, default: nil, desc: 'Include MCP server config'
      option :tests, type: :boolean, default: nil, desc: 'Include bats test scaffold'

      example [
        'my-plugin                        # Full scaffold with all components',
        'my-plugin --minimal              # Just manifests (plugin.json, marketplace.json)',
        'my-plugin --hooks                # Only hooks (for event-driven plugins)',
        'my-plugin --hooks --commands     # Hooks + slash commands',
        'my-plugin --agents --skills      # AI-focused plugin (agents + skills)',
        'my-plugin --commands --tests     # Commands with test scaffold',
        'my-suite --plugins 3             # Multi-plugin marketplace (core, hooks, extras)',
        'my-suite --plugins 4 --minimal   # Multi-plugin with minimal scaffolds'
      ]

      def call(name:, **options)
        validate_name!(name)
        check_directory!(name)
        validate_plugins_count!(options[:plugins])

        resolved_options = resolve_options(options)
        generator = Generator.new(name, resolved_options.merge(plugins: options[:plugins]))
        generator.run
      end

      private

      def validate_name!(name)
        # GitHub repo naming: alphanumeric, hyphens, underscores, dots
        # Must start with alphanumeric, no consecutive dots, no trailing dot
        return if name.match?(/\A[a-zA-Z0-9][a-zA-Z0-9._-]*\z/) && !name.match?(/\.\./) && !name.end_with?('.')

        puts 'Error: Invalid plugin name. ' \
             "Use letters, numbers, hyphens, underscores, or dots (e.g., 'my-plugin')"
        exit 1
      end

      def check_directory!(name)
        return unless Dir.exist?(name)

        puts "Error: Directory '#{name}' already exists"
        exit 1
      end

      def validate_plugins_count!(count)
        count_int = count.to_i
        return if count_int.positive? && count_int <= 10

        puts 'Error: --plugins must be between 1 and 10'
        exit 1
      end

      def resolve_options(options)
        # If --minimal, nothing gets included
        if options[:minimal]
          return {
            hooks: false, commands: false, agents: false,
            skills: false, mcp: false, tests: false
          }
        end

        # Check if any component flags were explicitly set
        component_flags = %i[hooks commands agents skills mcp tests]
        any_explicit = component_flags.any? { |f| !options[f].nil? }

        if any_explicit
          # Use explicit flags, default unset to false
          component_flags.each_with_object({}) do |flag, result|
            result[flag] = options[flag] || false
          end
        else
          # No flags = full (all components)
          component_flags.each_with_object({}) do |flag, result|
            result[flag] = true
          end
        end
      end
    end

    register 'version', Version, aliases: ['v', '-v', '--version']
    register 'new', New
  end
end
