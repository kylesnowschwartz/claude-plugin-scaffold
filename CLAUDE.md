# Claude Plugin Scaffold

A Ruby CLI tool that generates Claude Code plugin boilerplate.

## Project Structure

```
lib/
├── claude_plugin_scaffold.rb       # Main entry, loads dependencies
├── claude_plugin_scaffold/
│   ├── version.rb                  # VERSION constant
│   ├── cli.rb                      # dry-cli command definitions
│   ├── generator.rb                # Core generation logic
│   └── templates/                  # ERB templates for generated files
spec/                               # RSpec tests
homebrew-tap/                       # Homebrew formula for distribution
exe/claude-plugin-scaffold          # CLI entrypoint
```

## Key Files

- **`cli.rb`**: Defines `new` command with flags (`--minimal`, `--hooks`, `--plugins N`, etc.)
- **`generator.rb`**: Creates directory structure and renders ERB templates
- **`templates/`**: ERB files that become the scaffolded plugin files

## Architecture

1. User runs `claude-plugin-scaffold new my-plugin [flags]`
2. `CLI::New#call` validates name, resolves options
3. `Generator#run` creates directories and renders templates
4. Single plugin uses `plugin/` directory
5. Multi-plugin (`--plugins N`) uses `plugins/` with suffixes (core, hooks, extras, utils, styles)

## Development Commands

```bash
bundle exec rspec                    # Run tests (59 examples)
bundle exec rubocop                  # Lint
bundle exec exe/claude-plugin-scaffold new test-plugin  # Test locally
```

## Testing

- `spec/generator_spec.rb`: Tests file structure for flag combinations
- `spec/cli_spec.rb`: Tests name validation rules
- `spec/template_validation_spec.rb`: Validates generated JSON, shell, YAML

## Adding New Components

1. Add flag to `cli.rb` in the `New` command options
2. Add to `component_flags` array in `resolve_options`
3. Create template in `templates/`
4. Add `create_*` method in `generator.rb`
5. Call it from `create_plugin_components`
6. Add spec coverage

## Template Variables

Available in ERB templates via Generator binding:

- `name` - marketplace name
- `@current_plugin_name` - current plugin being generated
- `plugin_class_name` - PascalCase version
- `author_name` / `author_email` - from git config
- `current_year` - for LICENSE
- `multi_plugin?` - true if `--plugins > 1`
- `plugin_names` - array of plugin names to generate

## Plugin Naming

Valid names follow GitHub repo rules:
- Letters, numbers, hyphens, underscores, dots
- Must start with alphanumeric
- No consecutive dots, no trailing dot

## Release Process

**IMPORTANT: Only change version-specific values during a release. Do not refactor the formula.**

### Steps to release a new version

```bash
# 1. Bump version in code
# Edit lib/claude_plugin_scaffold/version.rb: VERSION = 'X.Y.Z'

# 2. Commit, push, and tag
git add -u && git commit -m "chore: bump version to X.Y.Z"
git push
git tag vX.Y.Z && git push origin vX.Y.Z

# 3. Get new SHA256
curl -sL https://github.com/kylesnowschwartz/claude-plugin-scaffold/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256

# 4. Update formula - ONLY these two lines:
#    url '...vX.Y.Z.tar.gz'
#    sha256 '<new-sha>'
# Edit: homebrew-tap/Formula/claude-plugin-scaffold.rb

# 5. Commit formula to main repo
git add homebrew-tap/Formula/claude-plugin-scaffold.rb
git commit -m "chore: bump formula to vX.Y.Z"
git push

# 6. Update the tap repo
cd /tmp/homebrew-claude-plugin-scaffold  # or clone fresh
git pull
cp /path/to/claude-plugin-scaffold/homebrew-tap/Formula/claude-plugin-scaffold.rb Formula/
git add Formula && git commit -m "chore: bump to vX.Y.Z" && git push

# 7. Create GitHub release (optional but nice)
gh release create vX.Y.Z --title "vX.Y.Z" --notes "Release notes here"

# 8. Test the upgrade locally
cd /usr/local/Homebrew/Library/Taps/kylesnowschwartz/homebrew-claude-plugin-scaffold
git fetch origin && git reset --hard origin/main
brew upgrade claude-plugin-scaffold
claude-plugin-scaffold --help  # verify it works
```

### What NOT to do during a release

- Do not refactor the formula install process
- Do not change how bundler/gem paths work
- Do not "simplify" working code
- Only change: version number, URL, SHA256

The formula's install process is delicate (bundler paths, GEM_HOME, RUBYLIB). If it works, leave it alone.
