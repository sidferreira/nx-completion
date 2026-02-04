# Nx completion plugin for Zsh

> This plugin brings Nx autocompletion to Zsh.

![demo](https://user-images.githubusercontent.com/8522558/111908149-67e8d780-8a58-11eb-9343-691f6d664163.gif)

## 🎉 Enhanced Features with Auto-Detect!

This plugin includes **enhanced features** that automatically activate when you create a `.nx-completion` config file:

- 🎯 **Target-aware filtering** - `nx start <TAB>` shows only projects with "start" target
- 🏆 **Smart priority ordering** - Applications first, test utilities last
- 🔄 **Unique project names** - `nx run <TAB>` shows each project once (no duplicates!)
- 📂 **Folder-aware priorities** - Boosts projects based on config settings
- ⚙️ **Config file support** - Drop `.nx-completion` in your workspace root
- 🤝 **Team sharing** - Config files in version control (commit and share!)

👉 **[See Enhanced Features Documentation](./ENHANCED-FEATURES.md)**

## Architecture

**Single unified plugin file with auto-detect activation:**

- **Standard Mode**: No `.nx-completion` file found → Original behavior
- **Enhanced Mode**: `.nx-completion` file exists → Advanced features enabled

The plugin walks up the directory tree looking for `.nx-completion` files and automatically enables enhanced features when found. No environment variables needed!

### Quick Start

```bash
# 1. Install as Oh My Zsh plugin
git clone git@github.com:sidferreira/nx-completion.git ~/.oh-my-zsh/custom/plugins/nx-completion

# 2. Add to ~/.zshrc
plugins+=(nx-completion)

# 3. Reload
exec zsh

# 4. (Optional) Enable enhanced features by creating config file
cd /path/to/nx/workspace
echo 'NX_PRIORITY_PROJECT_TYPES="application"' > .nx-completion

# 5. Try it!
nx start <TAB>  # Only shows projects with 'start' target!
```

---

## Standard Features

### Features

- ✅ **Dynamic command & option parsing**
  Automatically discovers and updates completions from `nx --help` output

- 🚀 **Intelligent caching = blazing fast completions**
  Leverages Nx's project graph cache and memoized command parsing

- 🧠 **Workspace-aware, always up-to-date**
  Auto-syncs completions with your Nx version, project executors, and custom generators

- 🧩 **Deep integration with Nx executors**
  Extracts and completes custom workspace commands, targets, and options

- ✨ **Smart autocompletion**
  Supports arguments, flags, projects, targets, and generators—all in context

- 📦 **Version flexibility**
  Works seamlessly across different Nx workspace versions

## Install

### Prerequisite

Install [`jq`](https://stedolan.github.io/jq/) dependency:

```shell
apt install jq
```

On MacOS you can install with:

```shell
brew install jq
```

> **Note**: [`jq`](https://stedolan.github.io/jq/) is a lightweight command-line JSON processor used to manipulate the workspace graph.

### As an [Oh My ZSH!](https://github.com/robbyrussell/oh-my-zsh) custom plugin

Clone the repository into the custom plugins directory:

```shell
git clone git@github.com:sidferreira/nx-completion.git ~/.oh-my-zsh/custom/plugins/nx-completion
```

Then load it as a plugin in your `.zshrc`:

```shell
plugins+=(nx-completion)
```

To enable enhanced features, create a `.nx-completion` file in your workspace root (see [Enhanced Features Documentation](./ENHANCED-FEATURES.md)).

### Manually

Clone this repository somewhere (`~/.nx-completion` for example):

```shell
git clone git@github.com:sidferreira/nx-completion.git ~/.nx-completion
```

Then source it in your `.zshrc`:

```shell
source ~/.nx-completion/nx-completion.plugin.zsh
```

To enable enhanced features, create a `.nx-completion` file in your workspace root (see [Enhanced Features Documentation](./ENHANCED-FEATURES.md)).

## Cache Management

When reinstalling or updating the nx-completion plugin, you may need to flush the zsh completion cache to ensure you're using the latest version.

### Quick Cache Clear

The simplest way to clear the zsh completion cache:

```shell
# Clear zsh completion cache and rebuild
rm -rf ~/.zcompdump* && autoload -U compinit && compinit -D
```

### Using the Clear Cache Script

Run the included script for automated cache clearing:

```shell
# Make executable and run
chmod +x clear-cache.zsh
./clear-cache.zsh
```

## Testing

This repository includes a comprehensive test environment in the `test/` directory with simplified project structures for easy testing and development.

### Test Environment Structure

```
test/
├── .nx/workspace-data/project-graph.json  # Main test graph (.nodes structure)
├── nx.json                                # Nx workspace config
├── project-graph-nested.json              # Test graph (.graph.nodes structure)
├── test-completion.zsh                    # Automated test script
├── test-cache.zsh                         # Cache performance test script
├── PERFORMANCE-TESTING.md                 # Real-world performance testing guide
└── README.md                              # Test environment docs
```

### Quick Testing

```bash
# Run automated tests
cd test && ./test-completion.zsh

# Test caching performance
cd test && ./test-cache.zsh

# Interactive completion testing
cd test
source ../nx-completion.plugin.zsh
nx <TAB>  # Test completions

# Performance testing guide
cd test && cat PERFORMANCE-TESTING.md
```

The test environment includes 5 projects (frontend-app, backend-api, shared-utils, ui-components, data-access) with realistic Nx configurations and supports testing both JSON structure formats.

## Enhanced Features

Enhanced features **automatically activate** when you create a `.nx-completion` file in your workspace!

For detailed documentation, see [ENHANCED-FEATURES.md](./ENHANCED-FEATURES.md).

### How Auto-Detect Works

The plugin walks up the directory tree looking for `.nx-completion` files:

- **Found** → Enhanced mode enabled + config loaded
- **Not found** → Standard mode (backward compatible)
- **Multiple files** → Closest ancestor wins

**Benefits:**
- No environment variables to configure
- Self-documenting (config file presence = enhanced mode)
- Team-friendly (commit `.nx-completion` to enable for everyone)
- Zero overhead when not in use

### Quick Examples

```bash
# Create config file to enable enhanced features
cd /path/to/nx/workspace
cat > .nx-completion <<EOF
NX_PRIORITY_PROJECT_TYPES="application"
NX_PRIORITY_TAGS="scope:mobile,scope:web"
NX_FOLDER_BOOST="200"
EOF

# Reload shell
exec zsh

# Target filtering - only shows projects with that target
nx start <TAB>     # Shows 3 projects, not 2053!
nx build <TAB>     # Only projects with 'build'

# No duplicates
nx run <TAB>       # Each project once, sorted by priority

# Projects prioritized by config
nx build <TAB>     # Applications first, then libraries
```

See [example-configs/](./example-configs/) for ready-to-use templates!

## What's Different in This Fork?

This fork includes powerful enhanced features with auto-detect activation:

1. **Target-aware filtering** - Shows only relevant projects
2. **Smart prioritization** - By projectType, tags, and context
3. **Auto-detect activation** - No environment variables needed
4. **Config file support** - `.nx-completion` files for team settings
5. **Backward compatible** - Standard mode unchanged

## License

This project is MIT licensed.
