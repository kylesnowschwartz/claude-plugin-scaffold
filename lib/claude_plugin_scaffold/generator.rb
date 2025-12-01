# frozen_string_literal: true

require 'erb'
require 'fileutils'

module ClaudePluginScaffold
  class Generator
    TEMPLATES_DIR = File.expand_path('templates', __dir__)

    attr_reader :name, :options, :base_path

    def initialize(name, options = {})
      @name = name
      @options = options
      @base_path = File.join(Dir.pwd, name)
    end

    def run
      create_base_structure
      create_plugin_manifest
      create_marketplace_manifest

      create_hooks if options[:hooks] || options[:full]
      create_commands if options[:commands] || options[:full]
      create_agents if options[:agents] || options[:full]
      create_skills if options[:skills] || options[:full]
      create_mcp if options[:mcp] || options[:full]
      create_tests if options[:tests] || options[:full]

      create_readme
      create_license
      create_gitignore

      puts "\nPlugin '#{name}' created successfully!"
      puts "  cd #{name}"
    end

    private

    def create_base_structure
      # Repository structure (like bumper-lanes, handoff)
      mkdir(base_path)
      mkdir(plugin_path)
      mkdir(File.join(plugin_path, '.claude-plugin'))
      mkdir(File.join(base_path, '.claude-plugin'))
    end

    def plugin_path
      @plugin_path ||= File.join(base_path, "#{name}-plugin")
    end

    def create_plugin_manifest
      write_template('plugin.json.erb', File.join(plugin_path, '.claude-plugin', 'plugin.json'))
      puts "  create #{name}-plugin/.claude-plugin/plugin.json"
    end

    def create_marketplace_manifest
      write_template('marketplace.json.erb', File.join(base_path, '.claude-plugin', 'marketplace.json'))
      puts '  create .claude-plugin/marketplace.json'
    end

    def create_hooks
      hooks_dir = File.join(plugin_path, 'hooks')
      mkdir(hooks_dir)
      mkdir(File.join(hooks_dir, 'entrypoints'))
      mkdir(File.join(hooks_dir, 'lib'))

      write_template('hooks/hooks.json.erb', File.join(hooks_dir, 'hooks.json'))
      write_template('hooks/session-start.sh.erb', File.join(hooks_dir, 'entrypoints', 'session-start.sh'),
                     executable: true)
      write_template('hooks/common.sh.erb', File.join(hooks_dir, 'lib', 'common.sh'))

      puts "  create #{name}-plugin/hooks/"
    end

    def create_commands
      commands_dir = File.join(plugin_path, 'commands')
      mkdir(commands_dir)

      write_template('commands/example.md.erb', File.join(commands_dir, 'example.md'))
      puts "  create #{name}-plugin/commands/"
    end

    def create_agents
      agents_dir = File.join(plugin_path, 'agents')
      mkdir(agents_dir)

      write_template('agents/example.md.erb', File.join(agents_dir, 'example.md'))
      puts "  create #{name}-plugin/agents/"
    end

    def create_skills
      skills_dir = File.join(plugin_path, 'skills')
      example_skill = File.join(skills_dir, 'example-skill')
      mkdir(skills_dir)
      mkdir(example_skill)

      write_template('skills/SKILL.md.erb', File.join(example_skill, 'SKILL.md'))
      puts "  create #{name}-plugin/skills/"
    end

    def create_mcp
      write_template('mcp.json.erb', File.join(plugin_path, '.mcp.json'))
      puts "  create #{name}-plugin/.mcp.json"
    end

    def create_tests
      tests_dir = File.join(base_path, 'tests')
      mkdir(tests_dir)
      mkdir(File.join(tests_dir, 'unit'))
      mkdir(File.join(tests_dir, 'integration'))
      mkdir(File.join(tests_dir, 'fixtures'))
      mkdir(File.join(tests_dir, 'test_helper'))

      write_template('tests/example.bats.erb', File.join(tests_dir, 'unit', 'example.bats'))
      write_template('tests/test_helper.bash.erb', File.join(tests_dir, 'test_helper', 'common.bash'))

      puts '  create tests/'
    end

    def create_readme
      write_template('README.md.erb', File.join(base_path, 'README.md'))
      puts '  create README.md'
    end

    def create_license
      write_template('LICENSE.erb', File.join(base_path, 'LICENSE'))
      puts '  create LICENSE'
    end

    def create_gitignore
      write_template('gitignore.erb', File.join(base_path, '.gitignore'))
      puts '  create .gitignore'
    end

    def mkdir(path)
      FileUtils.mkdir_p(path)
    end

    def write_template(template_name, destination, executable: false)
      template_path = File.join(TEMPLATES_DIR, template_name)
      content = render_template(template_path)
      File.write(destination, content)
      FileUtils.chmod(0o755, destination) if executable
    end

    def render_template(template_path)
      template = File.read(template_path)
      ERB.new(template, trim_mode: '-').result(binding)
    end

    # Template helpers
    def plugin_name
      name
    end

    def plugin_class_name
      name.split('-').map(&:capitalize).join
    end

    def author_name
      `git config user.name`.strip.presence || 'Your Name'
    end

    def author_email
      `git config user.email`.strip.presence || 'your@email.com'
    end

    def current_year
      Time.now.year
    end
  end
end

class String
  def presence
    empty? ? nil : self
  end
end
