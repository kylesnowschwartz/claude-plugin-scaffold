# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'
require 'json'

RSpec.describe ClaudePluginScaffold::Generator do
  let(:tmpdir) { Dir.mktmpdir }
  let(:name) { 'test-plugin' }

  after do
    FileUtils.rm_rf(tmpdir)
  end

  def generate(plugin_name, **options)
    Dir.chdir(tmpdir) do
      # Suppress stdout during generation
      original_stdout = $stdout
      $stdout = StringIO.new
      begin
        described_class.new(plugin_name, options).run
      ensure
        $stdout = original_stdout
      end
    end
  end

  def base_path
    File.join(tmpdir, name)
  end

  def files_in(path)
    Dir.glob(File.join(path, '**/*'), File::FNM_DOTMATCH)
       .select { |f| File.file?(f) }
       .map { |f| f.sub("#{path}/", '') }
       .sort
  end

  describe 'default (full) scaffold' do
    before { generate(name, hooks: true, commands: true, agents: true, skills: true, mcp: true, tests: true) }

    it 'creates marketplace manifest' do
      expect(File.exist?(File.join(base_path, '.claude-plugin', 'marketplace.json'))).to be true
    end

    it 'creates plugin manifest' do
      expect(File.exist?(File.join(base_path, 'plugin', '.claude-plugin', 'plugin.json'))).to be true
    end

    it 'creates hooks directory with all files' do
      hooks_path = File.join(base_path, 'plugin', 'hooks')
      expect(File.exist?(File.join(hooks_path, 'hooks.json'))).to be true
      expect(File.exist?(File.join(hooks_path, 'entrypoints', 'session-start.sh'))).to be true
      expect(File.exist?(File.join(hooks_path, 'lib', 'common.sh'))).to be true
    end

    it 'creates commands directory' do
      expect(File.exist?(File.join(base_path, 'plugin', 'commands', 'example.md'))).to be true
    end

    it 'creates agents directory' do
      expect(File.exist?(File.join(base_path, 'plugin', 'agents', 'example.md'))).to be true
    end

    it 'creates skills directory' do
      expect(File.exist?(File.join(base_path, 'plugin', 'skills', 'example-skill', 'SKILL.md'))).to be true
    end

    it 'creates mcp config' do
      expect(File.exist?(File.join(base_path, 'plugin', '.mcp.json'))).to be true
    end

    it 'creates tests directory' do
      expect(File.exist?(File.join(base_path, 'tests', 'unit', 'example.bats'))).to be true
      expect(File.exist?(File.join(base_path, 'tests', 'test_helper', 'common.bash'))).to be true
    end

    it 'creates standard files' do
      expect(File.exist?(File.join(base_path, 'README.md'))).to be true
      expect(File.exist?(File.join(base_path, 'LICENSE'))).to be true
      expect(File.exist?(File.join(base_path, '.gitignore'))).to be true
    end
  end

  describe '--minimal scaffold' do
    before { generate(name, hooks: false, commands: false, agents: false, skills: false, mcp: false, tests: false) }

    it 'creates marketplace manifest' do
      expect(File.exist?(File.join(base_path, '.claude-plugin', 'marketplace.json'))).to be true
    end

    it 'creates plugin manifest' do
      expect(File.exist?(File.join(base_path, 'plugin', '.claude-plugin', 'plugin.json'))).to be true
    end

    it 'does not create hooks' do
      expect(File.exist?(File.join(base_path, 'plugin', 'hooks'))).to be false
    end

    it 'does not create commands' do
      expect(File.exist?(File.join(base_path, 'plugin', 'commands'))).to be false
    end

    it 'does not create agents' do
      expect(File.exist?(File.join(base_path, 'plugin', 'agents'))).to be false
    end

    it 'does not create skills' do
      expect(File.exist?(File.join(base_path, 'plugin', 'skills'))).to be false
    end

    it 'does not create mcp config' do
      expect(File.exist?(File.join(base_path, 'plugin', '.mcp.json'))).to be false
    end

    it 'does not create tests' do
      expect(File.exist?(File.join(base_path, 'tests'))).to be false
    end

    it 'still creates standard files' do
      expect(File.exist?(File.join(base_path, 'README.md'))).to be true
      expect(File.exist?(File.join(base_path, 'LICENSE'))).to be true
    end
  end

  describe '--hooks only' do
    before { generate(name, hooks: true, commands: false, agents: false, skills: false, mcp: false, tests: false) }

    it 'creates hooks' do
      expect(File.exist?(File.join(base_path, 'plugin', 'hooks', 'hooks.json'))).to be true
    end

    it 'does not create commands' do
      expect(File.exist?(File.join(base_path, 'plugin', 'commands'))).to be false
    end

    it 'does not create agents' do
      expect(File.exist?(File.join(base_path, 'plugin', 'agents'))).to be false
    end
  end

  describe '--hooks --commands' do
    before { generate(name, hooks: true, commands: true, agents: false, skills: false, mcp: false, tests: false) }

    it 'creates hooks' do
      expect(File.exist?(File.join(base_path, 'plugin', 'hooks', 'hooks.json'))).to be true
    end

    it 'creates commands' do
      expect(File.exist?(File.join(base_path, 'plugin', 'commands', 'example.md'))).to be true
    end

    it 'does not create agents' do
      expect(File.exist?(File.join(base_path, 'plugin', 'agents'))).to be false
    end
  end

  describe '--agents --skills' do
    before { generate(name, hooks: false, commands: false, agents: true, skills: true, mcp: false, tests: false) }

    it 'creates agents' do
      expect(File.exist?(File.join(base_path, 'plugin', 'agents', 'example.md'))).to be true
    end

    it 'creates skills' do
      expect(File.exist?(File.join(base_path, 'plugin', 'skills', 'example-skill', 'SKILL.md'))).to be true
    end

    it 'does not create hooks' do
      expect(File.exist?(File.join(base_path, 'plugin', 'hooks'))).to be false
    end
  end

  describe '--plugins 3 (multi-plugin)' do
    before do
      generate(name, plugins: 3, hooks: true, commands: true, agents: true, skills: true, mcp: true, tests: true)
    end

    it 'creates marketplace manifest with 3 plugins' do
      manifest_path = File.join(base_path, '.claude-plugin', 'marketplace.json')
      expect(File.exist?(manifest_path)).to be true

      manifest = JSON.parse(File.read(manifest_path))
      expect(manifest['plugins'].length).to eq(3)
      expect(manifest['plugins'].map { |p| p['name'] }).to eq(%w[
                                                                test-plugin-core
                                                                test-plugin-hooks
                                                                test-plugin-extras
                                                              ])
    end

    it 'creates plugins directory (not plugin)' do
      expect(File.exist?(File.join(base_path, 'plugins'))).to be true
      expect(File.exist?(File.join(base_path, 'plugin'))).to be false
    end

    it 'creates each plugin with correct structure' do
      %w[core hooks extras].each do |suffix|
        plugin_dir = File.join(base_path, 'plugins', "test-plugin-#{suffix}")
        expect(File.exist?(File.join(plugin_dir, '.claude-plugin', 'plugin.json'))).to be true
        expect(File.exist?(File.join(plugin_dir, 'hooks', 'hooks.json'))).to be true
        expect(File.exist?(File.join(plugin_dir, 'commands', 'example.md'))).to be true
      end
    end

    it 'uses correct source paths in marketplace manifest' do
      manifest_path = File.join(base_path, '.claude-plugin', 'marketplace.json')
      manifest = JSON.parse(File.read(manifest_path))

      expect(manifest['plugins'][0]['source']).to eq('./plugins/test-plugin-core')
      expect(manifest['plugins'][1]['source']).to eq('./plugins/test-plugin-hooks')
      expect(manifest['plugins'][2]['source']).to eq('./plugins/test-plugin-extras')
    end
  end

  describe '--plugins 3 --minimal' do
    before do
      generate(name, plugins: 3, hooks: false, commands: false, agents: false, skills: false, mcp: false, tests: false)
    end

    it 'creates 3 plugins with manifests only' do
      %w[core hooks extras].each do |suffix|
        plugin_dir = File.join(base_path, 'plugins', "test-plugin-#{suffix}")
        expect(File.exist?(File.join(plugin_dir, '.claude-plugin', 'plugin.json'))).to be true
        expect(File.exist?(File.join(plugin_dir, 'hooks'))).to be false
        expect(File.exist?(File.join(plugin_dir, 'commands'))).to be false
      end
    end
  end
end
