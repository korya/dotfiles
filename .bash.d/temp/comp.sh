
_jbackup()
{
    local cur
    local prev
    local command

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD - 1]}

    if [ $COMP_CWORD -eq 1 ]; then
	COMPREPLY=( $(compgen -W '--user' -- $cur) )
    elif [ $COMP_CWORD -eq 2 -a "$prev" == --user ]; then
	[ ! -d "$backup_setting_dir" ] && return 0

	COMPREPLY=( $(compgen -W "$(ls ""$backup_setting_dir"" | \
	    sed 's/_list$//; s/_settings//' | sort | uniq)" -- $cur ) )
	return 0
    fi

    for ((i=0; i<${#COMP_WORDS[@]}-1; i++ )); do
	case "${COMP_WORDS[i]}" in
	now|restore|list|remind)
	    command="${COMP_WORDS[i]}"
	    break
	    ;;
	esac
    done

    if [ -z "$command" ]; then
	COMPREPLY=( "${COMPREPLY[@]}" $(compgen -W 'now restore list remind' \
	    -- $cur) )
	return 0
    fi

    case "$prev" in
    now)
	COMPREPLY=( $(compgen -W '--no_filelist' -- $cur) )
	;;
    restore|list)
	_filedir
	;;
    remind)
	COMPREPLY=( $(compgen -W '--list --test' -- $cur ) )
	;;
    --list)
	COMPREPLY=( $(compgen -W '--test' -- $cur ) )
	;;
    esac
}

backup_setting_dir="$PROJECT_PATH"
[ -z "$backup_setting_dir" ] && backup_setting_dir=$HOME/project
backup_setting_dir=$backup_setting_dir/system/backup

complete -F _jbackup -o filenames jbackup

