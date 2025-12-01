# frozen_string_literal: true

require 'English'
require 'tmpdir'
require 'fileutils'
require 'json'
require 'yaml'

RSpec.describe 'Template validation' do
  let(:tmpdir) { Dir.mktmpdir }
  let(:name) { 'validation-test' }
  let(:base_path) { File.join(tmpdir, name) }

  before do
    Dir.chdir(tmpdir) do
      original_stdout = $stdout
      $stdout = StringIO.new
      begin
        ClaudePluginScaffold::Generator.new(name, {
                                              hooks: true, commands: true, agents: true,
                                              skills: true, mcp: true, tests: true
                                            }).run
      ensure
        $stdout = original_stdout
      end
    end
  end

  after do
    FileUtils.rm_rf(tmpdir)
  end

  describe 'JSON files' do
    %w[
      .claude-plugin/marketplace.json
      plugin/.claude-plugin/plugin.json
      plugin/hooks/hooks.json
      plugin/.mcp.json
    ].each do |json_file|
      it "#{json_file} is valid JSON" do
        path = File.join(base_path, json_file)
        expect { JSON.parse(File.read(path)) }.not_to raise_error
      end
    end
  end

  describe 'shell scripts' do
    %w[
      plugin/hooks/entrypoints/session-start.sh
      plugin/hooks/lib/common.sh
      tests/test_helper/common.bash
    ].each do |shell_file|
      it "#{shell_file} passes shellcheck" do
        path = File.join(base_path, shell_file)
        # SC1091: Not following sourced files (expected, not an error)
        result = `shellcheck --exclude=SC1091 "#{path}" 2>&1`
        expect($CHILD_STATUS.success?).to be(true), "shellcheck failed:\n#{result}"
      end
    end
  end

  describe 'markdown with YAML frontmatter' do
    %w[
      plugin/commands/example.md
      plugin/agents/example.md
      plugin/skills/example-skill/SKILL.md
    ].each do |md_file|
      it "#{md_file} has valid YAML frontmatter" do
        path = File.join(base_path, md_file)
        content = File.read(path)

        expect(content).to start_with('---'), 'Missing frontmatter delimiter'

        parts = content.split('---', 3)
        expect(parts.length).to be >= 3, 'Invalid frontmatter structure'

        expect { YAML.safe_load(parts[1]) }.not_to raise_error
      end
    end
  end
end
