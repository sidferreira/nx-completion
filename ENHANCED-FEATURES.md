# Enhanced Nx-Completion - Complete Guide

**Auto-detect activation. Zero configuration. Team-friendly.**

---

## Features

✅ **Auto-detect activation** - Creates `.nx-completion` file → Enhanced features enabled
✅ **Target-aware filtering** - `nx start <TAB>` shows only projects with "start" target
✅ **Smart priority ordering** - Applications first, by projectType and tags
✅ **Unique project names** - `nx run <TAB>` shows each project once (no duplicates)
✅ **Config-driven priorities** - Folder boost and tag-based ordering
✅ **Team sharing** - Configs in version control, automatic for everyone
✅ **Fast** - Cached with auto-invalidation
✅ **Zero overhead** - Standard mode unchanged when config file absent

---

## Quick Start

### 1. Installation

```bash
# Install the plugin
git clone git@github.com:sidferreira/nx-completion.git ~/.oh-my-zsh/custom/plugins/nx-completion

# Add plugin to ~/.zshrc
plugins+=(nx-completion)

# Reload
exec zsh
```

**That's it!** No environment variables needed.

### 2. Enable Enhanced Features

```bash
# Create .nx-completion file in your workspace root
cd /path/to/nx/workspace
cat > .nx-completion <<EOF
NX_PRIORITY_PROJECT_TYPES="application"
NX_PRIORITY_TAGS="scope:mobile,scope:web"
EOF

# Reload
exec zsh
```

**Enhanced features now active!** 🎉

### 3. Try It

```bash
# Target filtering
nx start <TAB>
# Shows only: mobile-main, web-main, mobile-playground (3 projects, not 2053!)

# Unique names for 'run'
nx run <TAB>
# Shows each project once, applications first

# Priority ordering
nx build <TAB>
# Applications first, then libraries
```

### 4. Optional: Team-Specific Configs

```bash
# Commit config file to share with team
git add .nx-completion
git commit -m "Add enhanced completion config"
git push

# Now everyone on the team gets enhanced features automatically!
```

**Done!** 🎉

---

## How Auto-Detect Works

The plugin walks up the directory tree looking for `.nx-completion` files:

1. **Checks current directory** for `.nx-completion`
2. **Walks up parent directories** (up to 10 levels)
3. **If found** → Enhanced mode enabled + config loaded
4. **If not found** → Standard mode (backward compatible)

### Benefits

- **No environment variables** - Just create a file
- **Self-documenting** - Config file presence = enhanced mode
- **Team-friendly** - Commit to git → Everyone gets it
- **Workspace-specific** - Different settings per workspace
- **Zero overhead** - No performance cost when not in use

---

## How It Works

### 1. Target-Aware Filtering

**Problem:** `nx start <TAB>` shows all 2053 projects, but only 3 have "start" target

**Solution:** Queries project graph for projects with that specific target

```bash
nx start <TAB>
# Before: 2053 projects
# After:  3 projects (mobile-main, web-main, mobile-playground)
```

### 2. Priority Ordering

**Problem:** Projects shown alphabetically, not by relevance

**Solution:** Score-based prioritization

```
Score = Project Type (1000 for apps)
      + Priority Tags (100 each)
      - Deprioritize Tags (50 each)
      + Folder Boost (if in matching folder)
```

**Example:**
```bash
mobile-main (application, scope:mobile, type:app, audience:main)
= 1000 (app) + 100 (type:app) + 100 (audience:main) = 1200 points

shared-lib (library, type:lib)
= 0 (lib) + 0 (no matching tags) = 0 points

# mobile-main appears first!
```

### 3. Unique Project Names for 'nx run'

**Problem:** `nx run <TAB>` shows thousands of `project:target` combinations

**Solution:** Show each project once

```bash
# Before:
nx run <TAB>
# mobile-main:start
# mobile-main:build
# mobile-main:test
# mobile-main:lint
# ... (thousands of entries)

# After:
nx run <TAB>
# mobile-main (once)
# web-main
# mobile-playground
# ... (2053 unique projects, sorted)
```

### 4. Folder-Aware Priorities

**Problem:** Same priorities everywhere

**Solution:** Automatic boost based on current folder

```bash
cd apps/mobile
nx start <TAB>
# mobile-main gets +200 bonus (scope:mobile)

cd apps/web
nx start <TAB>
# web-main gets +200 bonus (scope:web)
```

**Built-in patterns:**
- `*/apps/mobile/*` → scope:mobile +200
- `*/apps/web/*` → scope:web +200
- `*/libs/mobile/*` → scope:mobile +150
- `*/libs/web/*` → scope:web +150
- `*/libs/shared/*` → scope:shared-front-end +100
- `*/main/*` → audience:main +150

### 5. Config File Support

**Problem:** Hard to customize per folder, not team-shareable

**Solution:** `.nx-completion` files in folders

```
workspace/
├── apps/
│   ├── mobile/
│   │   └── .nx-completion    ← Mobile settings
│   └── web/
│       └── .nx-completion    ← Web settings
└── libs/
    └── shared/
        └── .nx-completion    ← Shared libs settings
```

**Behavior:**
- Walks up directory tree (like `.gitignore`)
- Version controlled (whole team gets same settings)
- Auto-detected (no manual loading)
- Overrides fallback patterns

---

## Configuration

### Global Settings (Optional)

Add to `~/.zshrc` **before** sourcing the plugin:

```bash
# Prioritize applications
export NX_PRIORITY_PROJECT_TYPES="application"

# Prioritize these tags
export NX_PRIORITY_TAGS="type:app,audience:main"

# Deprioritize these tags
export NX_DEPRIORITIZE_TAGS="type:test-lib,type:e2e"

# Then source the plugin
source ~/.oh-my-zsh/custom/plugins/nx-completion/nx-completion-enhanced.zsh
```

### Config Files (Recommended for Teams)

Create `.nx-completion` in any folder:

```bash
# apps/mobile/.nx-completion
NX_PRIORITY_TAGS="scope:mobile,type:app,audience:main"
NX_DEPRIORITIZE_TAGS="scope:web,type:test-lib"
NX_FOLDER_BOOST="200"
```

**Variables:**
- `NX_PRIORITY_PROJECT_TYPES` - Project types to boost (e.g., "application")
- `NX_PRIORITY_TAGS` - Tags to boost (+100 each)
- `NX_DEPRIORITIZE_TAGS` - Tags to lower (-50 each)
- `NX_FOLDER_BOOST` - Extra boost for matching tags

---

## Examples

### Example 1: Mobile Developer

**Setup:**
```bash
cat > apps/mobile/.nx-completion <<EOF
NX_PRIORITY_TAGS="scope:mobile,type:app"
NX_DEPRIORITIZE_TAGS="scope:web"
NX_FOLDER_BOOST="200"
EOF
```

**Daily workflow:**
```bash
cd apps/mobile/main

nx start <TAB>
# Shows: mobile-main (1400), mobile-playground (1300), web-main (1200)

nx build <TAB>
# All projects with 'build', mobile first

nx run <TAB>
# All projects, mobile first, no duplicates
```

### Example 2: Full-Stack Developer

**Setup:**
```bash
# apps/mobile/.nx-completion
NX_PRIORITY_TAGS="scope:mobile,audience:main"
NX_FOLDER_BOOST="150"

# apps/web/.nx-completion
NX_PRIORITY_TAGS="scope:web,audience:main"
NX_FOLDER_BOOST="150"
```

**Workflow:**
```bash
# Morning: mobile work
cd apps/mobile
nx start <TAB>  # Mobile projects first

# Afternoon: web work
cd apps/web
nx start <TAB>  # Web projects first
```

### Example 3: Platform Team

**Setup:**
```bash
cat > libs/shared/.nx-completion <<EOF
NX_PRIORITY_PROJECT_TYPES="library"
NX_PRIORITY_TAGS="scope:shared-front-end,type:lib"
NX_DEPRIORITIZE_TAGS="type:app,type:test-lib"
NX_FOLDER_BOOST="150"
EOF
```

**Workflow:**
```bash
cd libs/shared
nx build <TAB>
# Shared libraries first, apps last
```

---

## Ready-to-Use Configs

Copy these to your workspace:

### Mobile Team
```bash
cat > apps/mobile/.nx-completion <<'EOF'
# Mobile team priorities
NX_PRIORITY_TAGS="scope:mobile,type:app,audience:main"
NX_DEPRIORITIZE_TAGS="scope:web,type:test-lib"
NX_FOLDER_BOOST="200"
EOF
```

### Web Team
```bash
cat > apps/web/.nx-completion <<'EOF'
# Web team priorities
NX_PRIORITY_TAGS="scope:web,type:app,audience:main"
NX_DEPRIORITIZE_TAGS="scope:mobile,type:test-lib"
NX_FOLDER_BOOST="200"
EOF
```

### Shared Libraries Team
```bash
cat > libs/shared/.nx-completion <<'EOF'
# Shared libraries team
NX_PRIORITY_PROJECT_TYPES="library"
NX_PRIORITY_TAGS="scope:shared-front-end,type:lib"
NX_DEPRIORITIZE_TAGS="type:app,type:test-lib"
NX_FOLDER_BOOST="150"
EOF
```

**Commit to share:**
```bash
git add apps/mobile/.nx-completion apps/web/.nx-completion libs/shared/.nx-completion
git commit -m "Add team completion configs"
git push
```

**Team members get it automatically:**
```bash
git pull
cd apps/mobile
nx start <TAB>  # Works immediately!
```

---

## Customization

### Add Your Own Tags

Check what tags exist in your workspace:

```bash
jq -r '.nodes[].data.tags[]' .nx/workspace-data/project-graph.json | sort -u
```

Use those in your config:

```bash
# .nx-completion
NX_PRIORITY_TAGS="your-actual-tag,another-tag"
```

### Add Custom Folder Patterns

Edit `nx-completion-enhanced.zsh` and add to `NX_FOLDER_RULES`:

```zsh
NX_FOLDER_RULES=(
  # Your custom patterns
  "*/features/trading/*"    "feature:trading|300"
  "*/team-alpha/*"          "team:alpha|400"

  # Existing patterns...
  "*/apps/mobile/*"         "scope:mobile|200"
  # ... etc
)
```

---

## Performance

### Benchmarks (Your Workspace: 2053 projects, 13MB)

```
Operation                      Time       Notes
─────────────────────────────  ─────────  ──────────────────
Target filtering (first)       ~580ms     Parse + filter
Target filtering (cached)      ~10ms      Cache hit
Priority calculation           <5ms       In-memory scoring
Config file lookup             <1ms       Cached per folder
Folder pattern matching        <1ms       Pattern matching
nx run completion (first)      ~580ms     Parse + score all
nx run completion (cached)     ~10ms      Cache hit
```

### Optimization Tips

1. **Config files are cached** - First completion in folder is slow, rest are fast
2. **Change folders?** - New cache created (expected)
3. **Want faster?** - Combine with performance optimizations from analysis doc:
   - In-memory JSON caching → 10-20x faster
   - Async pre-loading → instant completions

---

## Troubleshooting

### Issue: No projects shown for target

**Check if projects have that target:**
```bash
jq -r '.nodes[] | select(.data.targets.start != null) | .name' \
  .nx/workspace-data/project-graph.json
```

**Solution:** Target doesn't exist, or no projects have it

### Issue: Config file not working

**Debug:**
```bash
cd apps/mobile
# Should show: "Config file found: apps/mobile/.nx-completion"
nx <TAB>
```

**Solution:** Check file exists and has correct format

### Issue: Wrong priority order

**Debug priority scores:**
```bash
# Check project metadata
jq -r '.nodes."mobile-main" | {
  name,
  type: .data.projectType,
  tags: .data.tags
}' .nx/workspace-data/project-graph.json

# Calculate score manually:
# Base: 1000 (if application)
# +100 for each matching priority tag
# -50 for each matching deprioritize tag
# +FOLDER_BOOST if tags match
```

**Solution:** Adjust tags in config file

### Issue: Completion is slow

**First completion in folder:** Expected (~580ms)
**Subsequent completions:** Should be <50ms

**If always slow:**
1. Check if `.nx/workspace-data/project-graph.json` exists
2. Run `nx graph` once to generate cache
3. Consider performance optimizations (see analysis doc)

---

## Comparison: Before vs After

| Feature | Before | After |
|---------|--------|-------|
| `nx start <TAB>` | 2053 projects | 3 projects (filtered) |
| `nx run <TAB>` | Thousands of `project:target` | 2053 unique projects |
| Order | Alphabetical | Smart priority |
| Folder awareness | No | Yes (automatic) |
| Team sharing | Manual | Config files in git |
| Customization | Edit plugin | Drop config file |
| Performance | 425ms | 580ms first, 10ms cached |

---

## What's Included

**One file:** `nx-completion-enhanced.zsh`

**All features:**
1. ✅ Target-aware filtering
2. ✅ Priority ordering
3. ✅ Unique project names for 'run'
4. ✅ Folder-aware priorities (pattern-based)
5. ✅ Config file support
6. ✅ Caching & auto-invalidation

**No dependencies on other files!**

---

## Migration from Original Plugin

### Before
```bash
plugins=(nx-completion)
```

### After
```bash
plugins=(nx-completion)
source ~/.oh-my-zsh/custom/plugins/nx-completion/nx-completion-enhanced.zsh
```

**That's it!** No breaking changes, fully backward compatible.

---

## FAQ

**Q: Does this replace the original nx-completion plugin?**
A: No, it extends it. Keep the original plugin loaded.

**Q: Can I use this without config files?**
A: Yes! Config files are optional. It works great with just folder patterns.

**Q: Will this work for my team?**
A: Yes! Config files in git means everyone gets the same settings automatically.

**Q: How do I disable folder awareness?**
A: Set empty patterns: `NX_FOLDER_RULES=()` in the plugin file

**Q: Can I use JSON config files?**
A: Currently only shell format. JSON support can be added if needed.

**Q: What if I don't have mobile/web structure?**
A: Create your own patterns in `NX_FOLDER_RULES` or use config files

**Q: Does this slow down my shell?**
A: No. Only runs during TAB completion, not on every command.

---

## Support

**Issues?** Check:
1. Is original nx-completion plugin loaded?
2. Is `.nx/workspace-data/project-graph.json` present?
3. Run `nx graph` once to generate cache
4. Check config file format (shell variables)

**Performance issues?** See `nx-completion-performance-analysis.md` for advanced optimizations.

---

## Summary

**One file. All features. Team-ready.**

Install it, optionally add config files, and enjoy smart nx-completion! 🚀
