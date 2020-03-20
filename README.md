# hook.sh

Seamlessly extend any command with pre and post command hooks using vanilla bash.

`hook.sh` will try to find and execute *pre* and *post* functions matching the arguments passed to the **hook** command.

## Features

- **Pre and Post hooks** for any command
- **Local hooks** defined in `hooks.sh` relative to the current directory.
- **Global hooks** defined in a `.sh` that can be placed anywhere and defined by setting the *HOOK_GLOBAL_FILE* environment variable (must use a full path).
- **Hook** a command or a command with a specific set of arguments.
- **Configurable**: Override hook prefixes, filenames, and more.
- **Logging** available when setting *HOOK_LOG* environment variable to true.
- **Custom logging** and log level filtering by replacing the default logger using *HOOK_LOG_FUNC*.

## Configuration

**NOTE:** Override defaults by setting evironment variables in your shell before sourcing `hook.sh`.

Variable  | Default value  |  Description
--|---|--
HOOK_FILE  | `./hooks.sh`  | The relative path to a local hooks file.
HOOK_PREFIX  | `hook_`  |  The function name prefix used to identify a local hook and avoid collisions with other functions.
HOOK_GLOBAL_FILE  | -  | The path to a global hooks file.
HOOK_GLOBAL_PREFIX  | `global_`  | The function name prefix used to identify a global hook and avoid collisions with other functions. The final function name needs to be prefixed with both the global and local prefix (ie. global_hook_pre_terraform)
HOOK_LOG  | `false`  | When set to true, `hook.sh` will output debug logs.
HOOK_LOG_FUNC | `_hook_log_msg` | The name of the function used by hook to log message.

## Usage

1. Create a `hooks.sh` file in the directory where you want to run a command.
2. Create `hook_pre*` and/or `hook_post*` functions matching the command name and arguments you want to hook.
3. Source the `hook.sh` library in your shell.
4. Go to the directory where you created your `hooks.sh` file and run your command, prefixing it with the word **hook**.

### Example

**./examples/terraform/hooks.sh**
```bash
#!/usr/bin/env bash

hook_pre() {
  echo 'Always running before any command...'
}

hook_pre_terraform() {
  echo 'Always running before any terraform command...'
}

hook_pre_terraform_apply() {
  echo 'Running before terraform apply...'
}

hook_post_terraform_destroy() {
  echo 'Running after terraform destroy...'
}
```

**bash**
```bash
source ./hook.sh
cd ./examples/terraform/
alias terraform='hook terraform'
terraform init
terraform apply
```

**output**
```
Always running before any command...
Always running before any terraform command...
[terraform init ...]
Always running before any command...
Always running before any terraform command...
Running before terraform apply...
[terraform apply ...]
```

## Logging

To enable internal logging from `hook.sh`, set the environment variable `HOOK_LOG` to true.

### Log levels

The following log levels are used by `hook.sh` and is always the first argument passed to the log `HOOK_LOG_FUNC`.

- TRACE
- DEBUG
- INFO
- WARN
- ERROR

### Custom logger

To enable the use of a custom logger, simply set the `HOOK_LOG_FUNC` to the name of a function or binary that can handle logging for you.

```bash
awesome_log() {
  echo "[awesome-log] [$1] ${*:2}" ;;
}
export HOOK_LOG_FUNC='awesome_log'
```
### Log level filtering
He're an example of how to set up log level filtering using a custom logger:

```bash
filtered_log() {
  case $1 in
    TRACE | DEBUG) ;; # log nothing
    *) echo "[$1] ${*:2}" ;;
  esac
}
export HOOK_LOG_FUNC='filtered_log'
```
