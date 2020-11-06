# notifyosd.zsh

Just like `undistract-me`, this notifies you when a long running command completes, but for zsh.

## Installation
Just source notifyosd.zsh in your .zshrc:

```
source path/to/notifyosd.zsh
```

## Usage
The default timeout is set to 10s, this can be changed via the environment variable `NOTIFYOST_LONG_RUNNING_COMMAND_TIMEOUT`

Sound can be played on notification by setting `NOTIFYOSD_SOUND` to 1.




