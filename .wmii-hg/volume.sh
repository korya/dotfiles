
# Bar-Plugin API:
# <NAME>_events
# <NAME>_actions
# <NAME>_on_click
#
# <NAME>_BAR

export BARS="$BARS z1:volume"

volume()
{
    local control=Master
    # mute = Master is mutted
    local mute_control=Master

    [ -z "$1" ] && return 1

    case "$1" in
    up)
	amixer -c0 sset $control ${2-5}%+ >/dev/null
	;;
    down)
	amixer -c0 sset $control ${2-5}%- >/dev/null
	;;
    mute_toggle)
	( amixer -c0 sget $mute_control | grep -Ee '\[[0-9][0-9]*%\].*\[on\]' \
	    && amixer -c0 sset $mute_control mute || \
	    amixer -c0 sset $mute_control unmute ) >/dev/null
	;;
    status)
	progress='[--mute--]'
	amixer -c0 sget $mute_control | grep -Ee '\[[0-9][0-9]*%\].*\[on\]' \
	    >/dev/null && progress=$(amixer -c0 sget $control | \
	    grep -oEe '\[[0-9][0-9]*%\]' | sed 1\ q | tr -cd '0-9\n' \
	    | $HOME/bin/progress_bar -q -w 10 -e - -f X -L)
	echo "vol: $progress"
    esac
}

volume_actions()
{
    local VOLUME_BAR=$1; shift

    cat <<!
	Action volume
	    if wmiir remove /rbar/$VOLUME_BAR 2>/dev/null; then
		sleep 2
	    fi
	    echo "$WMII_NORMCOLORS" | wmiir create /rbar/$VOLUME_BAR
	    while volume status | wmiir write /rbar/$VOLUME_BAR; do
		sleep 1
	    done
!
}

volume_events()
{
    cat <<!
	Key $MODKEY-bracketleft
		volume down
	Key $MODKEY-bracketright
		volume up
	Key $MODKEY-backslash
		volume mute_toggle
!
}

volume_on_click()
{
    local btn=$1; shift

    echo 'volume bar was clicked with `'$btn"'" >/tmp/wmii.out

    case "$btn" in
	1) volume down ;;
	2) volume mute_toggle ;;
	3) volume up ;;
    esac
}
