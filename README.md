# Nx completion plugin for Zsh

> This plugin brings Nx autocompletion to Zsh.

![demo](https://user-images.githubusercontent.com/8522558/111908149-67e8d780-8a58-11eb-9343-691f6d664163.gif)

## 🎉 Enhanced Version Available!

This fork includes an **enhanced version** with powerful new features:

- 🎯 **Target-aware filtering** - `nx start <TAB>` shows only projects with "start" target
- 🏆 **Smart priority ordering** - Applications first, test utilities last
- 🔄 **Unique project names** - `nx run <TAB>` shows each project once (no duplicates!)
- 📂 **Folder-aware priorities** - Auto-detects mobile/web/libs context
- ⚙️ **Config file support** - Drop `.nx-completion` in folders for team settings
- 🤝 **Team sharing** - Config files in version control

👉 **[See Enhanced Features Documentation](./ENHANCED-FEATURES.md)**

### Quick Start with Enhanced Version

```bash
# Install as Oh My Zsh plugin
git clone git@github.com:sidferreira/nx-completion.git ~/.oh-my-zsh/custom/plugins/nx-completion

# Add to ~/.zshrc
plugins+=(nx-completion)
source ~/.oh-my-zsh/custom/plugins/nx-completion/nx-completion-enhanced.plugin.zsh

# Reload
exec zsh

# Try it!
nx start <TAB>  # Only shows projects with 'start' target!
```

---

## Standard Version (Original Plugin)

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
# Standard version
plugins+=(nx-completion)

# OR Enhanced version (recommended!)
plugins+=(nx-completion)
source ~/.oh-my-zsh/custom/plugins/nx-completion/nx-completion-enhanced.plugin.zsh
```

### Manually

Clone this repository somewhere (`~/.nx-completion` for example):

```shell
git clone git@github.com:sidferreira/nx-completion.git ~/.nx-completion
```

Then source it in your `.zshrc`:

```shell
# Standard version
source ~/.nx-completion/nx-completion.plugin.zsh

# OR Enhanced version (recommended!)
source ~/.nx-completion/nx-completion.plugin.zsh
source ~/.nx-completion/nx-completion-enhanced.plugin.zsh
```

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

## Enhanced Version Features

For detailed documentation on the enhanced features, see [ENHANCED-FEATURES.md](./ENHANCED-FEATURES.md).

### Quick Examples

```bash
# Target filtering - only shows projects with that target
nx start <TAB>     # Shows 3 projects, not 2053!
nx build <TAB>     # Only projects with 'build'

# No duplicates
nx run <TAB>       # Each project once, sorted by priority

# Folder awareness
cd apps/mobile
nx start <TAB>     # Mobile projects prioritized

# Config files for teams
cat > apps/mobile/.nx-completion <<EOF
NX_PRIORITY_TAGS="scope:mobile,type:app"
NX_FOLDER_BOOST="200"
EOF
```

See [example-configs/](./example-configs/) for ready-to-use templates!

## What's Different in This Fork?

This fork adds an enhanced plugin (`nx-completion-enhanced.plugin.zsh`) with:

1. **Target-aware filtering** - Shows only relevant projects
2. **Smart prioritization** - By projectType, tags, and context
3. **Folder awareness** - Auto-detects mobile/web/libs folders
4. **Config file support** - `.nx-completion` files for team settings
5. **No breaking changes** - Works alongside the standard plugin

## License

This project is MIT licensed.
