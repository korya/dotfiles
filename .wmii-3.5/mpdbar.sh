

# Prints current track playing
mpdbar_status() {
    if mpc 2>/dev/null | grep '\[playing\]' >/dev/null
    then
        mpc | head -1
    else
        echo "stopped"
    fi
}

# Uses $WMII_9MENU. The user can jump from the current track to [#curr-10,#curr+10].
mpdbar_track_menu() {
    set -- $(mpc | sed -n '2p' | cut -d' ' -f2 | tr '#/' '\n')
    track=$( $WMII_9MENU $(
        if [ "$2" -lt 21 ]; then
            mpc playlist
        else
            ( mpc playlist; mpc playlist; mpc playlist) | 
                tail -n +$( echo $2'+'$1'-15' | bc ) | head -n 31
        fi | sed 's/^>\(.*\)$/------> \1 <------/' | tr ' ' '\r'
        ) | tr '\r' ' ' | cut -d')' -f1
    )
    [ -n "$track" ] && mpc play "$track"
}

# Opens menu containing all saved playlists
mpdbar_load_playlist() {
    res=$($WMII_9MENU $(mpc lsplaylists | tr ' \t' '\r') | tr '\r' ' ')
    [ -n "$res" ] && mpc clear && mpc load "$res" && mpc play
}

# Saves the current playlist
mpdbar_save_playlist() {
    mpc save $(mpc playlist | head -1 | sed 's/^ [0-9]*) //' | tr '/-' '\n' | head -1 |
                $WMII_MENU -p 'Enter name' ) 2>/dev/null
}

# Initializing mpd bar
mpdbar_init() {
    wmiir remove /rbar/mpd 2>/dev/null && sleep 2
    echo "$WMII_NORMCOLORS" | wmiir create /rbar/mpd
    while mpdbar_status | wmiir write /rbar/mpd
    do
        sleep 1
    done &
}



# Prints the status of repeat mode - on|off
mpdbar_repeat_status() {
    mpc | tail -1 | awk '{print $4}'
}

# Prints the status of random mode - on|off
mpdbar_random_status() {
    mpc | tail -1 | awk '{ print $6}'
}

# Converts 'off' to 'on' or 'on' to 'off'
mpdbar_not() {
    while read line;
    do
        case "$line" in
        on) echo off ;;
        off) echo on ;;
        *) echo $@ ;;
        esac
    done
}

# Toggles repeat mode
mpdbar_repeat_toggle() {
    mpc repeat $(mpdbar_repeat_status | mpdbar_not) >/dev/null
}

# Toggles random mode
mpdbar_random_toggle() {
    mpc random $(mpdbar_random_status | mpdbar_not) >/dev/null
}

#
mpdbar_onClick() {
    case "$1" in
    1) mpc toggle ;;
    2) 
        if [ "$(wmiir read /rbar/mpd)" = "stopped" ]; then
            $WMII_9MENU $( (echo 'Statistics about MPD:';
                            echo '<------------------------------>';
                            mpc  stats) | tr ' \t' '\r' | tr ':' ';' ) >/dev/null
        else
            mpdbar_track_menu
        fi
        ;;
    3) 
        res=$($WMII_9MENU $((echo 'Load playlist:load';
                             echo 'Save current pl:save';
                             echo '----------------:nop';
                             echo -n 'Repeat turn '; echo -n $(mpdbar_repeat_status | mpdbar_not); echo ':repeat';
                             echo -n 'Random turn '; echo -n $(mpdbar_random_status | mpdbar_not); echo ':random';
                            ) | tr ' \t' '\r' )
             >/dev/null)
        case "$res" in
        load)   mpdbar_load_playlist ;;
        save)   mpdbar_save_playlist ;;
        repeat) mpdbar_repeat_toggle ;;
        random) mpdbar_random_toggle ;;
        esac
        ;;
    4) mpc next ;;
    5) mpc prev ;;
    esac
}

