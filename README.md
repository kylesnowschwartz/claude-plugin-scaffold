# Claude Plugin Scaffold

Scaffold Claude Code plugins with a single command.

## Installation

### Homebrew (macOS/Linux)

```bash
brew tap kylesnowschwartz/claude-plugin-scaffold
brew install claude-plugin-scaffold
```

Or install directly:

```bash
brew install kylesnowschwartz/claude-plugin-scaffold/claude-plugin-scaffold
```

### From Source

```bash
git clone https://github.com/kylesnowschwartz/claude-plugin-scaffold
cd claude-plugin-scaffold
bundle install
bundle exec exe/claude-plugin-scaffold --help
```

## Usage

### Create a new plugin

```bash
# Create a minimal plugin (just the manifest files)
claude-plugin-scaffold new my-plugin

# Create with specific components
claude-plugin-scaffold new my-plugin --hooks --commands

# Create with all components
claude-plugin-scaffold new my-plugin --full
```

### Available flags

| Flag | Description |
|------|-------------|
| `--hooks` | Include hooks boilerplate (hooks.json, entrypoint scripts) |
| `--commands` | Include commands directory with example command |
| `--agents` | Include agents directory with example agent |
| `--skills` | Include skills directory with example skill |
| `--mcp` | Include MCP server config (.mcp.json) |
| `--tests` | Include bats test scaffold |
| `--full` | Include all components |

### Generated structure

With `--full`, the generator creates:

```
my-plugin/
├── .claude-plugin/
│   └── marketplace.json     # Local marketplace for development
├── my-plugin-plugin/
│   ├── .claude-plugin/
│   │   └── plugin.json      # Plugin manifest
│   ├── hooks/
│   │   ├── hooks.json
│   │   ├── entrypoints/
│   │   │   └── session-start.sh
│   │   └── lib/
│   │       └── common.sh
│   ├── commands/
│   │   └── example.md
│   ├── agents/
│   │   └── example.md
│   ├── skills/
│   │   └── example-skill/
│   │       └── SKILL.md
│   └── .mcp.json
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── fixtures/
│   └── test_helper/
├── README.md
├── LICENSE
└── .gitignore
```

## Development

```bash
# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Run locally
bundle exec exe/claude-plugin-scaffold new test-plugin --full
```

## Publishing the Homebrew Tap

The `homebrew-tap/` directory contains the Homebrew formula. To publish:

1. Create a GitHub repository named `homebrew-claude-plugin-scaffold`
2. Copy the contents of `homebrew-tap/` to that repository
3. Create a git tag `v0.1.0` on this repository
4. Users can then install via `brew tap kylesnowschwartz/claude-plugin-scaffold`

## License

MIT
