# Claude Plugin Scaffold

Scaffold Claude Code plugins with a single command. Full scaffold by default, with flags to customize components or create multi-plugin marketplaces.

## Installation

### Homebrew (macOS/Linux)

```bash
brew tap kylesnowschwartz/claude-plugin-scaffold
brew install claude-plugin-scaffold
```

### Local install (from source)

```bash
# Install directly from local formula
brew install --formula ./homebrew-tap/Formula/claude-plugin-scaffold.rb
```

### Development

```bash
git clone https://github.com/kylesnowschwartz/claude-plugin-scaffold
cd claude-plugin-scaffold
bundle install
bundle exec exe/claude-plugin-scaffold --help
```

## Usage

```bash
# Full scaffold with all components (default)
claude-plugin-scaffold new my-plugin

# Minimal - just manifests (plugin.json, marketplace.json)
claude-plugin-scaffold new my-plugin --minimal

# Selective components
claude-plugin-scaffold new my-plugin --hooks                # Only hooks
claude-plugin-scaffold new my-plugin --hooks --commands     # Hooks + slash commands
claude-plugin-scaffold new my-plugin --agents --skills      # AI-focused plugin

# Multi-plugin marketplace (like SimpleClaude)
claude-plugin-scaffold new my-suite --plugins 3             # Creates core, hooks, extras
claude-plugin-scaffold new my-suite --plugins 4 --minimal   # Multi-plugin, manifests only
```

### Flags

| Flag | Description |
|------|-------------|
| `--minimal` | Create minimal plugin (manifests only) |
| `--plugins N` | Create N plugins in a marketplace (max 10) |
| `--hooks` | Include hooks boilerplate |
| `--commands` | Include commands directory |
| `--agents` | Include agents directory |
| `--skills` | Include skills directory |
| `--mcp` | Include MCP server config |
| `--tests` | Include bats test scaffold |

**Default behavior:**
- No flags = full scaffold (all components)
- Any component flag = only those components
- `--minimal` = manifests only, no components

### Generated structure

**Single plugin** (`claude-plugin-scaffold new my-plugin`):

```
my-plugin/
├── .claude-plugin/
│   └── marketplace.json
├── plugin/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── hooks/
│   │   ├── hooks.json
│   │   ├── entrypoints/session-start.sh
│   │   └── lib/common.sh
│   ├── commands/example.md
│   ├── agents/example.md
│   ├── skills/example-skill/SKILL.md
│   └── .mcp.json
├── tests/
├── README.md
├── LICENSE
└── .gitignore
```

**Multi-plugin marketplace** (`claude-plugin-scaffold new my-suite --plugins 3`):

```
my-suite/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── my-suite-core/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── hooks/
│   │   ├── commands/
│   │   └── ...
│   ├── my-suite-hooks/
│   │   └── ...
│   └── my-suite-extras/
│       └── ...
├── tests/
├── README.md
└── ...
```

## Development

```bash
# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Test a scaffold locally
bundle exec exe/claude-plugin-scaffold new test-plugin
```

## Publishing

### RubyGems

```bash
gem build claude-plugin-scaffold.gemspec
gem push claude-plugin-scaffold-0.1.0.gem
```

### Homebrew Tap

1. Create a GitHub repo named `homebrew-claude-plugin-scaffold`
2. Copy contents of `homebrew-tap/` to that repo
3. Tag a release: `git tag v0.1.0 && git push --tags`
4. Update formula URL to point to the release tarball

## License

MIT
