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
        validate_name!(name)
        check_directory!(name)

        generator = Generator.new(name, options)
        generator.run
      end

      private

      def validate_name!(name)
        return if name.match?(/\A[a-z][a-z0-9-]*[a-z0-9]\z/) || name.match?(/\A[a-z]+\z/)

        puts "Error: Plugin name must be kebab-case (e.g., 'my-plugin')"
        exit 1
      end

      def check_directory!(name)
        return unless Dir.exist?(name)

        puts "Error: Directory '#{name}' already exists"
        exit 1
      end
    end

    register 'version', Version, aliases: ['v', '-v', '--version']
    register 'new', New
  end
end
