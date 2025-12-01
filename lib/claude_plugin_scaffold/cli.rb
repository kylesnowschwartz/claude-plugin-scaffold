# frozen_string_literal: true

require 'dry/cli'

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
      desc 'Create a new Claude Code plugin'

      argument :name, required: true, desc: 'Plugin name (kebab-case)'

      option :hooks, type: :boolean, default: false, desc: 'Include hooks boilerplate'
      option :commands, type: :boolean, default: false, desc: 'Include commands directory'
      option :agents, type: :boolean, default: false, desc: 'Include agents directory'
      option :skills, type: :boolean, default: false, desc: 'Include skills directory'
      option :mcp, type: :boolean, default: false, desc: 'Include MCP server config'
      option :tests, type: :boolean, default: false, desc: 'Include bats test scaffold'
      option :full, type: :boolean, default: false, desc: 'Include all components'

      def call(name:, **options)
        puts "Creating plugin: #{name}"
        puts "Options: #{options.inspect}"
        # TODO: Implement generator
      end
    end

    register 'version', Version, aliases: ['v', '-v', '--version']
    register 'new', New
  end
end
