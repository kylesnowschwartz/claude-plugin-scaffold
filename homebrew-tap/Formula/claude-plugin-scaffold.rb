# frozen_string_literal: true

class ClaudePluginScaffold < Formula
  desc 'Scaffold Claude Code plugins with a single command'
  homepage 'https://github.com/kylesnowschwartz/claude-plugin-scaffold'
  url 'https://github.com/kylesnowschwartz/claude-plugin-scaffold/archive/refs/tags/v0.1.1.tar.gz'
  sha256 'e0fc7710a0bae94fdd2ad86726f82a5893d3cef74b2cdd610bec05a471bef678'
  license 'MIT'

  depends_on 'ruby'

  def install
    # Install dependencies via bundler
    bundle_path = libexec / 'bundle'
    system 'bundle', 'config', 'set', '--local', 'path', bundle_path
    system 'bundle', 'install'

    # Copy lib and exe to libexec
    libexec.install 'lib', 'exe'

    # Find the ruby version directory bundler created
    ruby_dir = Dir[bundle_path / 'ruby/*'].first

    # Create wrapper script with proper load paths
    (bin / 'claude-plugin-scaffold').write_env_script(
      libexec / 'exe/claude-plugin-scaffold',
      GEM_HOME: ruby_dir,
      GEM_PATH: ruby_dir,
      RUBYLIB: libexec / 'lib'
    )
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/claude-plugin-scaffold version")

    # Test scaffold creation
    system bin / 'claude-plugin-scaffold', 'new', 'test-plugin', '--minimal'
    assert_predicate testpath / 'test-plugin/plugin/.claude-plugin/plugin.json', :exist?
  end
end
