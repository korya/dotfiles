# Register the bar
BARS="$BARS z2:battery"

ALARM_COLORS='#121314 #ff9998 #ff2425'

BATTERY_NAME=BAT0
BATTERY_DETAILS="progress_bar lifetime is_suspended"
# BATTERY_PATH=/proc/acpi/battery/"$BATTERY_NAME"
BATTERY_PATH=/sys/class/power_supply/"$BATTERY_NAME"
# ADAPTER_NAME=AC0

# XXX: Find better solution.
# It seems that there should be a battery daemon. It will simplify all this
# module.
__dont_suspend()
{
    local SUSPEND_DONT_SUSPEND_FILE="/tmp/dont_suspend"

    case "$1" in
    toggle)
	if [ -f "$SUSPEND_DONT_SUSPEND_FILE" ]; then
	    rm "$SUSPEND_DONT_SUSPEND_FILE"
	else
	    touch "$SUSPEND_DONT_SUSPEND_FILE"
	fi
	;;
    *)
	test -f "$SUSPEND_DONT_SUSPEND_FILE"
	;;
    esac
}

battery()
{
    if [ ! -d "$BATTERY_PATH" ]; then
	return 1
    fi

    . "$BATTERY_PATH"/uevent
    local charging=
    local fill_char=X-
    [ "$POWER_SUPPLY_STATUS" = Charging ] && \
	charging=y && \
	fill_char=+-
    local total=$POWER_SUPPLY_CHARGE_FULL
    local cur=$POWER_SUPPLY_CHARGE_NOW
    local percent=$[ ($cur*100)/$total ]

    # Battery is too low -- shutdown.
    [ $percent -le 2 ] && [ -z "$charging" ] && \
	sudo shutdown -h now 'Power crysis.'

    case "$1" in
    percent)
	echo -n ${percent}%
	;;

    lifetime)
        rate=$POWER_SUPPLY_CURRENT_NOW
	if [ -z "$rate" -o "$rate" -eq 0 ]; then
	    echo -n '???'
	else
	    h=$[ $cur/$rate ]
	    m=$[ (($cur % $rate)*60)/$rate ]
	    [ $m -lt 10 ] && m=0$m
	    echo -n ${h}:${m}
	fi
	;;

    progress_bar)
# with +8 there will be at least one X until battery state is 5% or less.
	echo $[ $percent+8 ] | $HOME/bin/progress_bar -q -w 10 \
	    -f ${fill_char:0:1} -e ${fill_char:1:1} -L | tr -d '\n'
	;;

    is_suspended)
	__dont_suspend check && echo -n "(D)" || echo -n "(S)"
	;;

    by_details)
        for i in $BATTERY_DETAILS; do battery $i && echo -n ' '; done
        ;;

    set_details)
	local action=${2:0:1}
	local detail=${2:1}

	[ -z "$detail" ] && detail="$3"
	case "$action" in
	+)
	    [[ $BATTERY_DETAILS != *$detail* ]] && \
		BATTERY_DETAILS="$BATTERY_DETAILS $detail"
	    ;;
	-)
	    BATTERY_DETAILS="${BATTERY_DETAILS/ $detail/}"
	    ;;
        esac
	;;
    esac
}

battery_actions()
{
    BATTERY_BAR=$1; shift

    cat <<!
	Action battery
	    if wmiir remove /rbar/$BATTERY_BAR 2>/dev/null; then
		sleep 2
	    fi
	    echo "$WMII_NORMCOLORS" | wmiir create /rbar/$BATTERY_BAR
	    rc=\$?
	    while [ \$rc -eq 0 ];  do
		percent=\$(battery percent)
		details="bat: \$(battery by_details)"
		if [ \${percent%\%} -le 9 ]; then
			echo -n "$WMII_NORMCOLORS \$details" | \
			wmiir write /rbar/$BATTERY_BAR
			sleep .5
			echo -n "$ALARM_COLORS \$details" | \
			wmiir write /rbar/$BATTERY_BAR
			rc=\$?
			sleep .5
		else
			echo -n "$WMII_NORMCOLORS \$details" | \
			wmiir write /rbar/$BATTERY_BAR
			rc=\$?
			sleep 1m
		fi
	    done
!
}

# No need for `battery_events'

battery_on_click()
{
    case "$1" in
	1) battery set_details +lifetime ;;
	2) __dont_suspend toggle ;;
	3) battery set_details -lifetime ;;
    esac
}

# No battery -- no bar.
[ ! -d "$BATTERY_PATH" ] && \
    unset battery battery_events battery_on_click battery_actions

