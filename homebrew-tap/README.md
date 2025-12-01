# Homebrew Tap for Claude Plugin Scaffold

This is the Homebrew tap for [claude-plugin-scaffold](https://github.com/kylesnowschwartz/claude-plugin-scaffold).

## Installation

```bash
brew tap kylesnowschwartz/claude-plugin-scaffold
brew install claude-plugin-scaffold
```

Or install directly:

```bash
brew install kylesnowschwartz/claude-plugin-scaffold/claude-plugin-scaffold
```

## Usage

```bash
# Create a new plugin with all components
claude-plugin-scaffold new my-plugin --full

# Create a minimal plugin with just hooks
claude-plugin-scaffold new my-plugin --hooks

# See all options
claude-plugin-scaffold new --help
```

## Formulae

| Formula | Description |
|---------|-------------|
| claude-plugin-scaffold | Scaffold Claude Code plugins with a single command |

## Publishing This Tap

To use this as a Homebrew tap, create a GitHub repository named `homebrew-claude-plugin-scaffold` with the contents of this directory.

The repository structure should be:
```
homebrew-claude-plugin-scaffold/
├── Formula/
│   └── claude-plugin-scaffold.rb
└── README.md
```
