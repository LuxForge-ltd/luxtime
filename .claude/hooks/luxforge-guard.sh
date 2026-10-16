#!/usr/bin/env bash
# LuxForge agent governance guard for Claude Code (PreToolUse hook).
#
# Enforces the parts of the LuxForge agent rules that can be checked mechanically:
#   - no pushes, commits, merges or rebases on main, master or Dev (rule 8)
#
# Pull request merges are allowed (rule 7): the agent merges only on the operator's word
# in the conversation, which a hook cannot see, so the agent is trusted to check it.
#
# Claude Code passes the tool call as JSON on stdin. Exit code 2 blocks the call and
# shows stderr to Claude; exit code 0 allows it. The script needs only bash, sed, tr and
# git, so it runs in Git Bash on Windows, macOS, Linux and Claude Code cloud sessions.
# It is a safety net, not a parser: when unsure it blocks, and the agent asks the operator.

set -u
set -f  # no glob expansion when splitting commands into words

input=$(tr '\n\r' '  ')
protected_re='^(main|master|dev)$'

block() {
    echo "LuxForge governance blocked this: $1 Only the operator may do this; ask them (see AGENTS.md)." >&2
    exit 2
}

json_field() {
    # Extracts a top-level or nested JSON string value by key, keeping escaped characters.
    printf '%s' "$input" | sed -nE "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\\1/p" | head -n1
}

tool=$(json_field tool_name)

[ "$tool" = "Bash" ] || exit 0

command=$(json_field command | tr '[:upper:]' '[:lower:]')
cwd=$(json_field cwd | sed 's/\\\\/\//g')
[ -n "$cwd" ] && [ -d "$cwd" ] || cwd=.

current_branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null | tr '[:upper:]' '[:lower:]')
on_protected=0
[[ "$current_branch" =~ $protected_re ]] && on_protected=1

is_protected_ref() {
    # Normalises a refspec side (strips +, refs/heads/ and HEAD) and tests it.
    local ref=${1#+}
    ref=${ref#refs/heads/}
    [ "$ref" = "head" ] && ref=$current_branch
    [[ "$ref" =~ $protected_re ]]
}

# Split the shell command into simple segments on ; && || | and escaped newlines.
segments=$(printf '%s' "$command" | sed -E 's/\\n/;/g; s/(\&\&|\|\||;|\|)/\n/g')

while IFS= read -r segment; do
    [[ "$segment" =~ (^|[[:space:]])git[[:space:]] ]] || continue

    # Drop everything before "git" and git's own options such as -C <path>.
    words=(${segment#*git })
    index=0
    while [ $index -lt ${#words[@]} ] && [[ "${words[$index]}" == -* ]]; do
        case "${words[$index]}" in -c | -C | --git-dir | --work-tree) index=$((index + 1)) ;; esac
        index=$((index + 1))
    done
    subcommand=${words[$index]:-}
    rest=("${words[@]:$((index + 1))}")

    case "$subcommand" in
        push)
            positional=()
            for word in "${rest[@]}"; do
                case "$word" in
                    --all | --mirror) block "git push $word includes protected branches." ;;
                    -*) ;;
                    *) positional+=("$word") ;;
                esac
            done
            if [ ${#positional[@]} -le 1 ]; then
                # No refspec: git pushes the current branch.
                [ $on_protected -eq 1 ] && block "git push from protected branch '$current_branch'."
            else
                for refspec in "${positional[@]:1}"; do
                    destination=${refspec##*:}
                    source=${refspec%%:*}
                    if is_protected_ref "$destination" || { [ "$refspec" = "$source" ] && is_protected_ref "$source"; }; then
                        block "git push to protected branch ($refspec)."
                    fi
                done
            fi
            ;;
        commit | merge | rebase | cherry-pick | revert | am)
            [ $on_protected -eq 1 ] && block "git $subcommand on protected branch '$current_branch'. Create a phase branch first."
            ;;
    esac
done <<< "$segments"

exit 0
