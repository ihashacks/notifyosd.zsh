# Default timeout is 10 seconds.
LONG_RUNNING_COMMAND_TIMEOUT=${LONG_RUNNING_COMMAND_TIMEOUT:-10}

# Set to 0 to disable human readable time format. Enabled by default.
NOTIFYOSD_HUMAN=${NOTIFYOSD_HUMAN:-1}

# Play sound on notification. Disabled by default
UDM_PLAY_SOUND=${UDM_PLAY_SOUND:-0}

# Commands to ignore
if [ -z "$LONG_RUNNING_IGNORE_LIST" ]
then
    LONG_RUNNING_IGNORE_LIST=""
fi

# Figure out the active Tmux window
function active_tmux_window() {
    [ -n "$TMUX" ] || {
        echo notmux
        return 1
    }
    tmux display-message -p '#{window_id}'
}

function active_tmux_session() {
    [ -n "$TMUX" ] || {
        echo notmux
        return 1
    }
    tmux display-message -p '#{session_id}'
}

# Function taken from undistract-me, get the current window id
function active_window_id() {
    if [[ -n $DISPLAY ]] ; then
        xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}'
        return
    fi
    echo nowindowid
}

function is_window_unfocused() {
    [[ "$cmd_active_win" != $(active_window_id) ]] || [[ "$cmd_tmux_win" != $(active_tmux_window) ]]
}

# converts seconds to human readable time
function tohuman {
  local T=$1
  local D=$((T/86400))
  local H=$((T/3600%24))
  local M=$((T/60%60))
  local S=$((T%60))
  local d=""
  local h=""
  local m=""
  [[ $D > 0 ]] && d="${D}d "
  [[ $H > 0 ]] && h="${H}h "
  [[ $M > 0 ]] && m="${M}m "
  echo "$d$h$m${S}s"
}


# end and compare timer, notify-send if needed
function notifyosd-precmd() {
    retval=$?
    if [[ ${cmdignore[(r)$cmd_basename]} == $cmd_basename ]]; then
        return
    else
        if [ ! -z "$cmd" ]; then
            cmd_end=$(date +%s)
            ((cmd_secs=$cmd_end - $cmd_start))
        fi

        if [ ! -z "$cmd" -a $cmd_secs -gt ${LONG_RUNNING_COMMAND_TIMEOUT:-10} ] && is_window_unfocused; then
            if [ $retval -gt 0 ]; then
                cmdstat="with warning"
                sndstat="/usr/share/sounds/gnome/default/alerts/sonar.ogg"
                urgency="critical"
            else
                cmdstat="successfully"
                sndstat="/usr/share/sounds/gnome/default/alerts/glass.ogg"
                urgency="normal"
            fi

            if [ "$NOTIFYOSD_HUMAN" -gt 0 ]; then
                cmd_time=$(tohuman $cmd_secs)
            else
                cmd_time="$cmd_secs seconds"
            fi

            tmux_info=''
            if active_tmux_window >/dev/null; then
                tmux_info=" (tmux: $(tmux display-message -p '#{session_name}/#{window_name}'))"
            fi

            sshhost_info=''
            if [ ! -z $SSH_TTY ] ; then
                sshhost_info=" on $(hostname)"
            fi

            notify-send -i utilities-terminal \
                    -u $urgency "$cmd_basename$sshhost_info completed $cmdstat" "\"$cmd\" took $cmd_time$tmux_info"

            if [ "$UDM_PLAY_SOUND" != "0" ]
            then
                play -q $sndstat
            fi
        fi
        unset cmd
    fi
}

# make sure this plays nicely with any existing precmd
precmd_functions+=( notifyosd-precmd )

# get command name and start the timer
function notifyosd-preexec() {
    cmd=$1
    cmd_basename=${${cmd:s/sudo //}[(ws: :)1]} 
    cmd_start=$(date +%s)
    cmd_active_win=$(active_window_id)
    cmd_tmux_win=$(active_tmux_window)
    cmd_tmux_session=$(active_tmux_session)
}

# make sure this plays nicely with any existing preexec
preexec_functions+=( notifyosd-preexec )
