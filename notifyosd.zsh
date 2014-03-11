# commands to ignore
cmdignore=(htop tmux top vim)

# end and compare timer, notify-send if needed
function notifyosd-precmd() {
	retval=$?
    if [[ ${cmdignore[(r)$cmd_basename]} == $cmd_basename ]]; then
        return
    else
        if [ ! -z "$cmd" ]; then
            cmd_end=`date +%s`
            ((cmd_time=$cmd_end - $cmd_start))
        fi
        if [ $retval -gt 0 ]; then
			cmdstat="with warning"
			sndstat="/usr/share/sounds/gnome/default/alerts/sonar.ogg"
		else
            cmdstat="successfully"
			sndstat="/usr/share/sounds/gnome/default/alerts/glass.ogg"
        fi
        if [ ! -z "$cmd" -a $cmd_time -gt 10 ]; then
            if [ ! -z $SSH_TTY ] ; then
                notify-send -i utilities-terminal -u low "$cmd_basename on `hostname` completed $cmdstat" "\"$cmd\" took $cmd_time seconds"; play -q $sndstat
            else
                notify-send -i utilities-terminal -u low "$cmd_basename completed $cmdstat" "\"$cmd\" took $cmd_time seconds"; play -q $sndstat
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
    cmd_start=`date +%s`
}

# make sure this plays nicely with any existing preexec
preexec_functions+=( notifyosd-preexec )
