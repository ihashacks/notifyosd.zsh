# notifyosd.zsh

Just like `undistract-me`, this notifies you when a long running command completes, but for zsh.

## Installation
Just source `notifyosd.zsh` in your `~.zshrc`:

```
source path/to/notifyosd.zsh
```

## Usage
Configuration is done with environment variables:
* `LONG_RUNNING_COMMAND_TIMEOUT`: to change the timeout, the default being 10s
* `UDM_PLAY_SOUND`: need to be set to a non zero value to play sound together with the notification
* `NOTIFYOSD_HUMAN`: defines if human readable format should be adopted for the command duration, default is true, but
  can be disabled by setting this variable to `0`.
* `LONG_RUNNING_IGNORE_LIST`: is a list of command that will be ignored by the script

Note that a notification appears only if the terminal where the long command was running is not in focus.
