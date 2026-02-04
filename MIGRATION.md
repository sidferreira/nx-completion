# Migration Guide: Enhanced Plugin Merge

## What Changed?

Enhanced features are now **built into the main plugin** with **auto-detect activation**!

### Before (v1)
- Two separate plugin files: `nx-completion.plugin.zsh` and `nx-completion-enhanced.plugin.zsh`
- Required environment variable: `export NX_COMPLETE_ENHANCED=true`
- Manual setup in `.zshrc`

### After (v2)
- **Single unified plugin file**: `nx-completion.plugin.zsh`
- **Auto-detect activation**: Enhanced features enable when `.nx-completion` file exists
- **No environment variables needed**
- **Team-friendly**: Commit config file to enable for everyone

## Migration Steps

### For Individual Users

If you previously had:

```bash
# ~/.zshrc
export NX_COMPLETE_ENHANCED=true
plugins+=(nx-completion)
```

**Now do:**

1. Remove the environment variable from `~/.zshrc`:
   ```bash
   # Remove this line:
   # export NX_COMPLETE_ENHANCED=true

   # Keep this:
   plugins+=(nx-completion)
   ```

2. Create `.nx-completion` file in your workspace root:
   ```bash
   cd /path/to/nx/workspace
   cat > .nx-completion <<EOF
   NX_PRIORITY_PROJECT_TYPES="application"
   NX_PRIORITY_TAGS="scope:mobile,scope:web"
   NX_FOLDER_BOOST="200"
   EOF
   ```

3. Reload shell:
   ```bash
   exec zsh
   ```

### For Teams

**Best practice:** Commit `.nx-completion` to your repository

```bash
# Create workspace-wide config
cd /path/to/nx/workspace
cat > .nx-completion <<EOF
# Enhanced completion settings for this workspace
NX_PRIORITY_PROJECT_TYPES="application"
NX_PRIORITY_TAGS="scope:mobile,scope:web"
EOF

# Commit and push
git add .nx-completion
git commit -m "feat: enable enhanced completion for team"
git push
```

**Now everyone who pulls the repo gets enhanced features automatically!**

### Optional: Folder-Specific Configs

You can also create configs in subfolders:

```bash
# Mobile team config
cat > apps/mobile/.nx-completion <<EOF
NX_PRIORITY_TAGS="scope:mobile,type:app"
NX_FOLDER_BOOST="200"
EOF

# Web team config
cat > apps/web/.nx-completion <<EOF
NX_PRIORITY_TAGS="scope:web,type:app"
NX_FOLDER_BOOST="200"
EOF
```

The plugin walks up the directory tree and uses the closest `.nx-completion` file.

## Breaking Changes

None! The plugin is fully backward compatible:

- **Without `.nx-completion` file**: Works exactly like before (standard mode)
- **With `.nx-completion` file**: Enhanced features automatically activate

## Deprecation Notice

The separate `nx-completion-enhanced.plugin.zsh` file is now deprecated. It has been replaced with a migration notice that guides users to the new approach.

## Benefits of the New Approach

✅ **Simpler setup** - No environment variables to configure
✅ **Self-documenting** - Config file presence = enhanced mode
✅ **Team-friendly** - Commit config file to enable for everyone
✅ **Workspace-specific** - Different settings per workspace
✅ **Zero overhead** - No performance cost when not in use
✅ **Discoverable** - New team members see config file and learn about features

## Rollback

If you need to temporarily disable enhanced features:

```bash
# Rename config file
mv .nx-completion .nx-completion.bak

# Reload
exec zsh
```

To re-enable:

```bash
# Restore config file
mv .nx-completion.bak .nx-completion

# Reload
exec zsh
```

## Support

- See [ENHANCED-FEATURES.md](./ENHANCED-FEATURES.md) for full documentation
- See [example-configs/](./example-configs/) for ready-to-use templates
- Report issues: https://github.com/sidferreira/nx-completion/issues
