# frozen_string_literal: true

class ClaudePluginScaffold < Formula
  desc 'Scaffold Claude Code plugins with a single command'
  homepage 'https://github.com/kylesnowschwartz/claude-plugin-scaffold'
  url 'https://github.com/kylesnowschwartz/claude-plugin-scaffold/archive/refs/tags/v0.1.1.tar.gz'
  sha256 '173f89df3024a4fdd5a914484df6c482e24db979272570a88eb135b1c5275e70'
  license 'MIT'

  depends_on 'ruby'

  def install
    ENV['GEM_HOME'] = libexec

    # Install dependencies and build gem
    system 'bundle', 'config', 'set', '--local', 'path', libexec
    system 'bundle', 'install'
    system 'gem', 'build', 'claude-plugin-scaffold.gemspec'
    system 'gem', 'install', '--install-dir', libexec, '--no-document',
           "claude-plugin-scaffold-#{version}.gem"

    # Install binary with proper environment
    (bin / 'claude-plugin-scaffold').write_env_script(
      libexec / 'bin/claude-plugin-scaffold',
      GEM_HOME: libexec,
      GEM_PATH: libexec
    )
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/claude-plugin-scaffold version")

    # Test scaffold creation
    system bin / 'claude-plugin-scaffold', 'new', 'test-plugin', '--minimal'
    assert_predicate testpath / 'test-plugin/plugin/.claude-plugin/plugin.json', :exist?
  end
end
