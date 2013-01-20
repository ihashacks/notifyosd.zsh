function notifyosd-precmd() {
    if [ "$cmd" != "" ]; then
        cmd_end=`date +%s`
        ((cmd_time=$cmd_end - $cmd_start))
    fi                                                                                                                              
    if [ "$cmd" != "" -a $cmd_time -gt 10 ]; then
        notify-send -i utilities-terminal -u low "$cmd_basename completed" "\"$cmd\" took $cmd_time seconds"
    fi
}

precmd_functions+=( notifyosd-precmd )


function precmd() {
    title "zsh" "%m:%55<...<%~"
}

function notifyosd-preexec() {
    cmd=$1
    cmd_basename=${cmd[(ws: :)1]}
    cmd_start=`date +%s`
}

preexec_functions+=( notifyosd-preexec )