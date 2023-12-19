# Register the bar
export BARS="$BARS z0:mpd"

mpd_status()
{
    mpc 2>/dev/null | grep '\[playing\]' >/dev/null && \
	mpc | head -1 || echo "stopped"
}

mpd_actions()
{
    local BAR=$1; shift

    cat <<!
	Action mpd
	    wmiir remove /rbar/$BAR 2>/dev/null && sleep 2
	    echo "$WMII_NORMCOLORS" | wmiir create /rbar/$BAR
	    while mpd_status | wmiir write /rbar/$BAR; do
		sleep 1
	    done
!
}

mpd_events()
{
    cat <<!
	Key $MODKEY-z
		mpc prev >/dev/null
	Key $MODKEY-x
		mpc play >/dev/null
	Key $MODKEY-c
		mpc toggle >/dev/null
	Key $MODKEY-v
		mpc stop >/dev/null
	Key $MODKEY-b
		mpc next >/dev/null
	Key $MODKEY-Shift-z
		mpc seek -5% >/dev/null
	Key $MODKEY-Shift-b
		mpc seek +5% >/dev/null
!
}

mpd_on_click()
{
    case "$1" in
	1) mpc prev ;;
	2) mpc toggle ;;
	3) mpc next ;;
    esac
}
