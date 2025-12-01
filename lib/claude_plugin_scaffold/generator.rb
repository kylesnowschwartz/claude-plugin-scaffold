# frozen_string_literal: true

require 'erb'
require 'fileutils'

module ClaudePluginScaffold
  class Generator
    TEMPLATES_DIR = File.expand_path('templates', __dir__)

    # Default plugin suffixes for multi-plugin marketplaces
    PLUGIN_SUFFIXES = %w[core hooks extras utils styles].freeze

    attr_reader :name, :options, :base_path

    def initialize(name, options = {})
      @name = name
      @options = options
      @base_path = File.join(Dir.pwd, name)
    end

    def run
      mkdir(base_path)
      mkdir(File.join(base_path, '.claude-plugin'))

      if multi_plugin?
        create_multi_plugin_structure
      else
        create_single_plugin_structure
      end

      create_tests if options[:tests]
      create_readme
      create_license
      create_gitignore

      puts "\nMarketplace '#{name}' created successfully!"
      puts "  cd #{name}"
    end

    private

    def multi_plugin?
      plugin_count > 1
    end

    def plugin_count
      (options[:plugins] || 1).to_i
    end

    def plugin_names
      @plugin_names ||= if multi_plugin?
                          PLUGIN_SUFFIXES.take(plugin_count).map { |suffix| "#{name}-#{suffix}" }
                        else
                          [name] # Single plugin uses marketplace name
                        end
    end

    # Single plugin: my-marketplace/plugin/
    def create_single_plugin_structure
      @current_plugin_name = name
      plugin_dir = File.join(base_path, 'plugin')
      mkdir(plugin_dir)
      mkdir(File.join(plugin_dir, '.claude-plugin'))

      create_plugin_manifest(plugin_dir, name)
      create_plugin_components(plugin_dir, name)
      create_marketplace_manifest
    end

    # Multi-plugin: my-marketplace/plugins/my-marketplace-core/, etc.
    def create_multi_plugin_structure
      plugins_dir = File.join(base_path, 'plugins')
      mkdir(plugins_dir)

      plugin_names.each do |plugin_name|
        @current_plugin_name = plugin_name
        plugin_dir = File.join(plugins_dir, plugin_name)
        mkdir(plugin_dir)
        mkdir(File.join(plugin_dir, '.claude-plugin'))

        create_plugin_manifest(plugin_dir, plugin_name)
        create_plugin_components(plugin_dir, plugin_name)
      end

      create_marketplace_manifest
    end

    def create_plugin_manifest(plugin_dir, plugin_name)
      @current_plugin_name = plugin_name
      write_template('plugin.json.erb', File.join(plugin_dir, '.claude-plugin', 'plugin.json'))
      relative_path = plugin_dir.sub("#{base_path}/", '')
      puts "  create #{relative_path}/.claude-plugin/plugin.json"
    end

    def create_plugin_components(plugin_dir, plugin_name)
      @current_plugin_name = plugin_name

      create_hooks(plugin_dir, plugin_name) if options[:hooks]
      create_commands(plugin_dir, plugin_name) if options[:commands]
      create_agents(plugin_dir, plugin_name) if options[:agents]
      create_skills(plugin_dir, plugin_name) if options[:skills]
      create_mcp(plugin_dir, plugin_name) if options[:mcp]
    end

    def create_marketplace_manifest
      write_template('marketplace.json.erb', File.join(base_path, '.claude-plugin', 'marketplace.json'))
      puts '  create .claude-plugin/marketplace.json'
    end

    def create_hooks(plugin_dir, plugin_name)
      hooks_dir = File.join(plugin_dir, 'hooks')
      mkdir(hooks_dir)
      mkdir(File.join(hooks_dir, 'entrypoints'))
      mkdir(File.join(hooks_dir, 'lib'))

      @current_plugin_name = plugin_name
      write_template('hooks/hooks.json.erb', File.join(hooks_dir, 'hooks.json'))
      write_template('hooks/session-start.sh.erb', File.join(hooks_dir, 'entrypoints', 'session-start.sh'),
                     executable: true)
      write_template('hooks/common.sh.erb', File.join(hooks_dir, 'lib', 'common.sh'))

      relative_path = plugin_dir.sub("#{base_path}/", '')
      puts "  create #{relative_path}/hooks/"
    end

    def create_commands(plugin_dir, plugin_name)
      commands_dir = File.join(plugin_dir, 'commands')
      mkdir(commands_dir)

      @current_plugin_name = plugin_name
      write_template('commands/example.md.erb', File.join(commands_dir, 'example.md'))
      relative_path = plugin_dir.sub("#{base_path}/", '')
      puts "  create #{relative_path}/commands/"
    end

    def create_agents(plugin_dir, plugin_name)
      agents_dir = File.join(plugin_dir, 'agents')
      mkdir(agents_dir)

      @current_plugin_name = plugin_name
      write_template('agents/example.md.erb', File.join(agents_dir, 'example.md'))
      relative_path = plugin_dir.sub("#{base_path}/", '')
      puts "  create #{relative_path}/agents/"
    end

    def create_skills(plugin_dir, plugin_name)
      skills_dir = File.join(plugin_dir, 'skills')
      example_skill = File.join(skills_dir, 'example-skill')
      mkdir(skills_dir)
      mkdir(example_skill)

      @current_plugin_name = plugin_name
      write_template('skills/SKILL.md.erb', File.join(example_skill, 'SKILL.md'))
      relative_path = plugin_dir.sub("#{base_path}/", '')
      puts "  create #{relative_path}/skills/"
    end

    def create_mcp(plugin_dir, plugin_name)
      @current_plugin_name = plugin_name
      write_template('mcp.json.erb', File.join(plugin_dir, '.mcp.json'))
      relative_path = plugin_dir.sub("#{base_path}/", '')
      puts "  create #{relative_path}/.mcp.json"
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
