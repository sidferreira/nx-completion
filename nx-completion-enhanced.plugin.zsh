#!/bin/zsh
# ============================================================================
# DEPRECATED: nx-completion-enhanced.plugin.zsh
# ============================================================================
#
# Enhanced features are now built into nx-completion.plugin.zsh!
#
# Migration steps:
# 1. Remove references to this file from your ~/.zshrc
# 2. Remove 'export NX_COMPLETE_ENHANCED=true' from ~/.zshrc
# 3. Create a .nx-completion file in your workspace to enable enhanced features
# 4. Reload your shell: exec zsh
#
# Example .nx-completion file:
#   NX_PRIORITY_PROJECT_TYPES="application"
#   NX_PRIORITY_TAGS="scope:mobile,scope:web"
#   NX_FOLDER_BOOST="200"
#
# ============================================================================

echo ""
echo "⚠️  nx-completion-enhanced.plugin.zsh is DEPRECATED!"
echo ""
echo "Enhanced features are now built into the main plugin file."
echo "They activate automatically when you create a .nx-completion file."
echo ""
echo "📋 Migration steps:"
echo "   1. Remove references to nx-completion-enhanced.plugin.zsh from ~/.zshrc"
echo "   2. Remove 'export NX_COMPLETE_ENHANCED=true' from ~/.zshrc"
echo "   3. Create .nx-completion file in your workspace root"
echo "   4. Reload: exec zsh"
echo ""
echo "📄 Example .nx-completion file:"
echo "   NX_PRIORITY_PROJECT_TYPES=\"application\""
echo "   NX_PRIORITY_TAGS=\"scope:mobile,scope:web\""
echo "   NX_FOLDER_BOOST=\"200\""
echo ""
echo "✨ Benefits of the new approach:"
echo "   - No environment variables to configure"
echo "   - Team-shareable config files (commit to git)"
echo "   - Self-documenting (config file = enhanced mode)"
echo "   - Zero overhead when not in use"
echo ""
