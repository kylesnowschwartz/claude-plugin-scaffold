# frozen_string_literal: true

require_relative "lib/claude_plugin_scaffold/version"

Gem::Specification.new do |spec|
  spec.name = "claude-plugin-scaffold"
  spec.version = ClaudePluginScaffold::VERSION
  spec.authors = ["Kyle Snow Schwartz"]
  spec.email = ["kyle.snowschwartz@gmail.com"]

  spec.summary = "Scaffold Claude Code plugins with a single command"
  spec.description = "A CLI tool to generate Claude Code plugin boilerplate with customizable components (hooks, commands, agents, skills, MCP servers)"
  spec.homepage = "https://github.com/kylesnowschwartz/claude-plugin-scaffold"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-cli", "~> 1.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
