#!/bin/zsh
# Enhanced nx-completion with config file support
#
# Features:
# 1. Target-aware filtering
# 2. Priority ordering (applications first, by tags)
# 3. Unique project names for 'nx run'
# 4. Folder-aware priorities (pattern-based)
# 5. CONFIG FILE SUPPORT (NEW!)
#
# Config files (.nx-completion) in folders automatically apply settings:
#   - Drop .nx-completion in apps/mobile/ → mobile settings apply
#   - Drop .nx-completion in apps/web/ → web settings apply
#   - Settings are version-controlled and team-shared!

# Global defaults (can be overridden by config files or env vars)
typeset -g NX_PRIORITY_PROJECT_TYPES="${NX_PRIORITY_PROJECT_TYPES:-}"
typeset -g NX_PRIORITY_TAGS="${NX_PRIORITY_TAGS:-}"
typeset -g NX_DEPRIORITIZE_TAGS="${NX_DEPRIORITIZE_TAGS:-}"
typeset -g NX_FOLDER_BOOST="${NX_FOLDER_BOOST:-}"

# Config file name to look for
typeset -g NX_CONFIG_FILE=".nx-completion"

# Cache for config file lookups
typeset -gA _NX_CONFIG_CACHE
typeset -g _NX_CONFIG_CACHE_DIR=""

# Find .nx-completion config file by walking up directory tree
_nx_find_config() {
  local dir="$PWD"
  local max_depth=10
  local depth=0

  # Check cache first
  if [[ "$_NX_CONFIG_CACHE_DIR" == "$dir" ]] && [[ -n "${_NX_CONFIG_CACHE[path]}" ]]; then
    echo "${_NX_CONFIG_CACHE[path]}"
    return 0
  fi

  # Walk up directory tree
  while [[ "$dir" != "/" ]] && [[ $depth -lt $max_depth ]]; do
    if [[ -f "$dir/$NX_CONFIG_FILE" ]]; then
      # Cache the result
      _NX_CONFIG_CACHE[path]="$dir/$NX_CONFIG_FILE"
      _NX_CONFIG_CACHE[mtime]=$(stat -f %m "$dir/$NX_CONFIG_FILE" 2>/dev/null || stat -c %Y "$dir/$NX_CONFIG_FILE" 2>/dev/null)
      _NX_CONFIG_CACHE_DIR="$dir"

      echo "$dir/$NX_CONFIG_FILE"
      return 0
    fi

    dir="${dir:h}"  # Move up one directory
    ((depth++))
  done

  # Cache negative result
  _NX_CONFIG_CACHE[path]=""
  _NX_CONFIG_CACHE_DIR="$PWD"
  return 1
}

# Load and apply config file settings
_nx_load_config() {
  local config_file=$(_nx_find_config)

  if [[ -z "$config_file" ]]; then
    # No config file, use global defaults
    return 0
  fi

  # Check if config changed since last load
  local current_mtime=$(stat -f %m "$config_file" 2>/dev/null || stat -c %Y "$config_file" 2>/dev/null)
  if [[ "${_NX_CONFIG_CACHE[loaded_mtime]}" == "$current_mtime" ]]; then
    # Already loaded this version
    return 0
  fi

  # Safe parsing without eval - read line by line
  while IFS='=' read -r key value; do
    # Remove leading/trailing whitespace from key
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"

    # Skip empty lines and comments
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue

    # Remove leading/trailing whitespace from value
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    # Remove quotes from value if present
    if [[ "$value" =~ ^\"(.*)\"$ ]]; then
      value="${match[1]}"
    elif [[ "$value" =~ ^\'(.*)\'$ ]]; then
      value="${match[1]}"
    fi

    # Whitelist valid configuration keys and set them safely
    case "$key" in
      NX_PRIORITY_PROJECT_TYPES)
        typeset -g NX_PRIORITY_PROJECT_TYPES="$value"
        ;;
      NX_PRIORITY_TAGS)
        typeset -g NX_PRIORITY_TAGS="$value"
        ;;
      NX_DEPRIORITIZE_TAGS)
        typeset -g NX_DEPRIORITIZE_TAGS="$value"
        ;;
      NX_FOLDER_BOOST)
        typeset -g NX_FOLDER_BOOST="$value"
        ;;
      *)
        # Silently ignore unknown keys
        ;;
    esac
  done < "$config_file"

  # Mark as loaded
  _NX_CONFIG_CACHE[loaded_mtime]="$current_mtime"
  _NX_CONFIG_CACHE[config_dir]="${config_file:h}"

  return 0
}

# Get current target from command line
_nx_get_current_target() {
  echo "${words[1]}"
}

# Fallback folder rules (if no config file)
# These are example patterns - users should create .nx-completion files
# with their workspace-specific tags instead of relying on these defaults
typeset -gA NX_FOLDER_RULES
NX_FOLDER_RULES=(
  # Examples (commented out - uncomment and customize for your workspace):
  # "*/apps/mobile/*"           "scope:mobile|200"
  # "*/apps/web/*"              "scope:web|200"
  # "*/libs/*"                  "type:lib|100"
)

# Detect folder context (pattern-based or from config)
_nx_detect_folder_context() {
  local pwd="$PWD"

  # First check for config file
  local config_file=$(_nx_find_config)
  if [[ -n "$config_file" ]]; then
    # Config file exists, load its settings
    _nx_load_config

    # If config defines a folder boost, return it
    if [[ -n "$NX_FOLDER_BOOST" ]]; then
      # Config-based boost applies to all matching tags in priority list
      echo "${NX_PRIORITY_TAGS}|${NX_FOLDER_BOOST}"
      return 0
    fi
  fi

  # Fallback to pattern-based detection
  local -a context_tags=()
  local -a context_scores=()

  for pattern rule in ${(kv)NX_FOLDER_RULES}; do
    if [[ "$pwd" == $~pattern ]]; then
      local tags="${rule%%|*}"
      local score="${rule##*|}"
      context_tags+=("$tags")
      context_scores+=("$score")
    fi
  done

  if [[ ${#context_tags} -gt 0 ]]; then
    local tags_joined="${(j:,:)context_tags}"
    local scores_joined="${(j:,:)context_scores}"
    echo "${tags_joined}|${scores_joined}"
  fi
}

# Get projects with metadata for a specific target
_get_projects_with_target_metadata() {
  local target="$1"
  integer ret=1
  local cache_key="nx_projects_metadata_${target}"
  local cache_policy

  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    echo "${(P)cache_key[@]}"
    return 0
  fi

  local def=$(_workspace_def)
  if [[ ! -f "$def" ]]; then
    return 1
  fi

  local nodes_path=$(_get_nodes_path "$def")
  local -a projects=()

  if [[ "$nodes_path" == ".graph.nodes" ]]; then
    projects=($(jq -r --arg target "$target" '
      .graph.nodes[] |
      select(.data.targets[$target] != null) |
      .name + "|" + (.data.projectType // "library") + "|" + (.data.tags // [] | join(","))
    ' "$def" 2>/dev/null))
  else
    projects=($(jq -r --arg target "$target" '
      .nodes[] |
      select(.data.targets[$target] != null) |
      .name + "|" + (.data.projectType // "library") + "|" + (.data.tags // [] | join(","))
    ' "$def" 2>/dev/null))
  fi

  if [[ ${#projects} -gt 0 ]]; then
    eval "${cache_key}=(\"\${projects[@]}\")"
    _store_cache "$cache_key" "${cache_key}"
    echo "${projects[@]}" && ret=0
  fi

  return ret
}

# Calculate priority score (config-aware)
_calculate_project_priority() {
  local project_type="$1"
  local tags="$2"
  local score=0

  # Load config if present
  _nx_load_config

  # Base priority: project types
  local -a priority_types=(${(s:,:)NX_PRIORITY_PROJECT_TYPES})
  for ptype in $priority_types; do
    if [[ "$project_type" == "$ptype" ]]; then
      score=$((score + 1000))
      break
    fi
  done

  # Global priority tags
  local -a priority_tags=(${(s:,:)NX_PRIORITY_TAGS})
  for ptag in $priority_tags; do
    if [[ "$tags" == *"$ptag"* ]]; then
      score=$((score + 100))
    fi
  done

  # Global deprioritize tags
  local -a deprio_tags=(${(s:,:)NX_DEPRIORITIZE_TAGS})
  for dtag in $deprio_tags; do
    if [[ "$tags" == *"$dtag"* ]]; then
      score=$((score - 50))
    fi
  done

  # Folder context boost
  local context=$(_nx_detect_folder_context)
  if [[ -n "$context" ]]; then
    local context_tags="${context%%|*}"
    local context_scores="${context##*|}"

    local -a ctx_tags=(${(s:,:)context_tags})
    local -a ctx_scores=(${(s:,:)context_scores})

    for i in {1..${#ctx_tags}}; do
      local ctx_tag="${ctx_tags[$i]}"
      local ctx_score="${ctx_scores[$i]}"

      if [[ "$tags" == *"$ctx_tag"* ]]; then
        score=$((score + ctx_score))
      fi
    done
  fi

  echo "$score"
}

# Get projects with target, sorted by priority
_get_projects_with_target_sorted() {
  local target="$1"
  local -a projects_metadata=($(_get_projects_with_target_metadata "$target"))

  if [[ ${#projects_metadata} -eq 0 ]]; then
    return 1
  fi

  local -a scored_projects=()
  for entry in $projects_metadata; do
    local project="${entry%%|*}"
    local rest="${entry#*|}"
    local project_type="${rest%%|*}"
    local tags="${rest#*|}"

    local score=$(_calculate_project_priority "$project_type" "$tags")
    scored_projects+=("${score}|${project}")
  done

  local -a sorted_projects=(${(On)scored_projects})

  local -a result=()
  for entry in $sorted_projects; do
    result+=("${entry#*|}")
  done

  echo "${result[@]}"
}

# Simple version without sorting
_get_projects_with_target() {
  local target="$1"
  local -a projects=($(_get_projects_with_target_sorted "$target"))

  if [[ ${#projects} -eq 0 ]]; then
    local def=$(_workspace_def)
    if [[ ! -f "$def" ]]; then
      return 1
    fi

    local nodes_path=$(_get_nodes_path "$def")

    if [[ "$nodes_path" == ".graph.nodes" ]]; then
      projects=($(jq -r --arg target "$target" '
        .graph.nodes[] |
        select(.data.targets[$target] != null) |
        .name
      ' "$def" 2>/dev/null))
    else
      projects=($(jq -r --arg target "$target" '
        .nodes[] |
        select(.data.targets[$target] != null) |
        .name
      ' "$def" 2>/dev/null))
    fi
  fi

  echo "${projects[@]}"
}

# List projects filtered by target
_list_projects_with_target() {
  [[ $PREFIX = -* ]] && return 1
  integer ret=1

  local target=$(_nx_get_current_target)

  case "$target" in
    run|run-many|affected|graph|list|migrate|init|repair|reset|report|show|generate|g|add|import|login|exec|watch|daemon|release|connect|sync|view-logs|format)
      _list_projects
      return $?
      ;;
  esac

  local -a projects=($(_get_projects_with_target_sorted "$target"))

  if [[ ${#projects} -eq 0 ]]; then
    _list_projects
    return $?
  fi

  local -a filtered_projects=()
  if [[ -n "$PREFIX" ]]; then
    filtered_projects=(${(M)projects:#${PREFIX}*})
  else
    filtered_projects=($projects)
  fi

  if [[ ${#filtered_projects} -gt $NX_MAX_RESULTS ]]; then
    filtered_projects=(${filtered_projects[1,$NX_MAX_RESULTS]})
  fi

  if [[ ${#filtered_projects} -gt 0 ]]; then
    local expl
    local desc="Projects with '$target' target"

    # Add config file indicator if present
    local config_file=$(_nx_find_config)
    if [[ -n "$config_file" ]]; then
      local config_dir="${config_file:h}"
      local rel_path="${config_dir#$PWD}"
      [[ "$rel_path" == "$config_dir" ]] && rel_path="$(basename $config_dir)"
      desc="$desc (config: ${rel_path:-.})"
    fi

    _description nx-projects-filtered expl "$desc"
    compadd "$expl[@]" -a filtered_projects && ret=0
  fi

  return ret
}

# List unique projects for 'run' command
_list_projects_for_run() {
  [[ $PREFIX = -* ]] && return 1
  integer ret=1

  local config_file=$(_nx_find_config)
  local config_hash=""
  if [[ -n "$config_file" ]]; then
    config_hash=$(echo "$config_file" | md5 -r 2>/dev/null | awk '{print $1}')
  else
    local pwd_hash=$(echo "$PWD" | md5 -r 2>/dev/null | awk '{print $1}')
    config_hash="$pwd_hash"
  fi

  local cache_key="nx_all_projects_sorted_${config_hash}"
  local cache_policy

  zstyle -s ":completion:${curcontext}:" cache-policy cache_policy
  if [[ -z "$cache_policy" ]]; then
    zstyle ":completion:${curcontext}:" cache-policy _nx_caching_policy
  fi

  if ( [[ ${(P)+cache_key} -eq 1 ]] && ! _cache_invalid "$cache_key" ); then
    local -a cached_projects=("${(P@)cache_key}")

    local -a filtered_projects=()
    if [[ -n "$PREFIX" ]]; then
      filtered_projects=(${(M)cached_projects:#${PREFIX}*})
    else
      filtered_projects=(${cached_projects[1,$NX_MAX_RESULTS]})
    fi

    if [[ ${#filtered_projects} -gt 0 ]]; then
      local expl
      _description nx-projects expl "Projects"
      compadd "$expl[@]" -a filtered_projects && ret=0
    fi
    return ret
  fi

  local def=$(_workspace_def)
  if [[ ! -f "$def" ]]; then
    return 1
  fi

  local nodes_path=$(_get_nodes_path "$def")
  local -a projects_metadata=()

  if [[ "$nodes_path" == ".graph.nodes" ]]; then
    projects_metadata=($(jq -r '
      .graph.nodes[] |
      .name + "|" + (.data.projectType // "library") + "|" + (.data.tags // [] | join(","))
    ' "$def" 2>/dev/null))
  else
    projects_metadata=($(jq -r '
      .nodes[] |
      .name + "|" + (.data.projectType // "library") + "|" + (.data.tags // [] | join(","))
    ' "$def" 2>/dev/null))
  fi

  local -a scored_projects=()
  for entry in $projects_metadata; do
    local project="${entry%%|*}"
    local rest="${entry#*|}"
    local project_type="${rest%%|*}"
    local tags="${rest#*|}"

    local score=$(_calculate_project_priority "$project_type" "$tags")
    scored_projects+=("${score}|${project}")
  done

  local -a sorted_projects=(${(On)scored_projects})

  local -a result=()
  for entry in $sorted_projects; do
    result+=("${entry#*|}")
  done

  eval "${cache_key}=(\"\${result[@]}\")"
  _store_cache "$cache_key" "${cache_key}"

  local -a filtered_projects=()
  if [[ -n "$PREFIX" ]]; then
    filtered_projects=(${(M)result:#${PREFIX}*})
  else
    filtered_projects=(${result[1,$NX_MAX_RESULTS]})
  fi

  if [[ ${#filtered_projects} -gt 0 ]]; then
    local expl
    _description nx-projects expl "Projects"
    compadd "$expl[@]" -a filtered_projects && ret=0
  fi

  return ret
}

# Override _nx_command (same structure as before)
_nx_command_with_config() {
  integer ret=1
  local -a _command_args opts_help opts_affected

  opts_help=("--help[Shows a help message for this command in the console]")
  opts_affected=(
    "--base[Base of the current branch]:sha:"
    "--head[Latest commit of the current branch]:sha:"
    "--files[Change the way Nx is calculating the affected command]:files:_files"
    "--uncommitted[Uncommitted changes]"
    "--untracked[Untracked changes]"
    "--version[Show version number]"
    "--target[Task to run for affected projects]:target:"
    "--output-style[Defines how Nx emits outputs tasks logs]:output:"
    "--nx-bail[Stop command execution after the first failed task]"
    "--nx-ignore-cycles[Ignore cycles in the task graph]"
    "--parallel[Parallelize the command]"
    "--all[All projects]"
    "--exclude[Exclude certain projects]:projects:_list_projects"
    "--runner[This is the name of the tasks runner]:runner:"
    "--configuration[This is the configuration to use]:configuration:"
    "--verbose[Print additional error stack trace on failure]"
    "--skip-nx-cache[Rerun the tasks even when the results are available in the cache]"
  )

  case "$words[1]" in
    (b|build|e|e2e|l|lint|s|serve|t|test)
      # Target-aware commands
      local -a cmd_opts=($(_nx_get_command_options "${words[1]}"))
      if [[ ${#cmd_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $cmd_opts \
          ":project:_list_projects_with_target" && ret=0
      else
        _arguments $(_nx_arguments) \
          $opts_help \
          "(-c --configuration)"{-c=,--configuration=}"[Configuration]:configuration:" \
          ":project:_list_projects_with_target" && ret=0
      fi
    ;;
    (run|run-one)
      local -a run_opts=($(_nx_get_command_options "run"))
      if [[ ${#run_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $run_opts \
          ":project:_list_projects_for_run" && ret=0
      else
        _arguments $(_nx_arguments) \
          $opts_help \
          "(-c --configuration)"{-c=,--configuration=}"[Configuration]:configuration:" \
          ":project:_list_projects_for_run" && ret=0
      fi
    ;;
    (*)
      local command_name="${words[1]}"
      local -a dynamic_opts=($(_nx_get_command_options "$command_name"))

      if [[ ${#dynamic_opts} -gt 0 ]]; then
        _arguments $(_nx_arguments) \
          $opts_help \
          $dynamic_opts \
          ":project:_list_projects_with_target" && ret=0
      else
        _arguments $(_nx_arguments) \
          $opts_help \
          ":project:_list_projects_with_target" && ret=0
      fi
    ;;
  esac

  return ret
}

# Replace original _nx_command
_nx_command() {
  _nx_command_with_config "$@"
}

# Display loaded configuration
echo "✅ Config-aware nx-completion loaded!"
echo ""

# Check for config file
CONFIG=$(_nx_find_config)
if [[ -n "$CONFIG" ]]; then
  echo "📄 Config file found: $CONFIG"
  _nx_load_config
  echo "   Priority types: $NX_PRIORITY_PROJECT_TYPES"
  echo "   Priority tags:  $NX_PRIORITY_TAGS"
  if [[ -n "$NX_FOLDER_BOOST" ]]; then
    echo "   Folder boost:   $NX_FOLDER_BOOST"
  fi
else
  echo "📂 No .nx-completion file found (using global settings)"
  echo "   Priority types: $NX_PRIORITY_PROJECT_TYPES"
  echo "   Priority tags:  $NX_PRIORITY_TAGS"
fi
echo ""
echo "💡 Create .nx-completion in any folder to customize priorities"
