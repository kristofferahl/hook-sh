# hook.sh

Seamlessly extend any command with pre and post command hooks using vanilla bash.

`hook.sh` will try to find and execute *pre* and *post* functions matching the arguments passed to the **hook** command.

## Features

- **Pre and Post hooks** for any command
- **Local hooks** defined in `hooks.sh` relative to the current directory.
- **Global hooks** defined in a `.sh` that can be placed anywhere and defined by setting the *HOOK_GLOBAL_FILE* environment variable (must use a full path).
- **Hook** a command or a command with a specific set of arguments.
- **Configurable**: Override hook prefixes, filenames, and more.
- **Debug logging** available when setting *HOOK_LOG* environment variable to true.

## Configuration

Override defaults by setting evironment variables in your shell before sourcing `hook.sh`.

Variable  | Default value  |  Description
--|---|--
HOOK_FILE  | ./hooks.sh  | The relative path to a local hooks file.
HOOK_PREFIX  | hook_  |  The function name prefix used to identify a local hook and avoid collisions with other functions.
HOOK_GLOBAL_FILE  | -  | The path to a global hooks file.
HOOK_GLOBAL_PREFIX  | global_  | The function name prefix used to identify a global hook and avoid collisions with other functions. The final function name needs to be prefixed with both the global and local prefix (ie. global_hook_pre_terraform)
HOOK_LOG  | false  | When set to true, `hook.sh` will output debug logs.

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
  echo 'Always running before any command passed to hook...'
}

hook_pre_terraform() {
  echo 'Always running before any terraform command...'
}

hook_pre_terraform_apply() {
  echo 'Running before applying terraform changes...'
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
Always running before any command passed to hook...
Always running before any terraform command...
[terraform init ...]
Always running before any command passed to hook...
Always running before any terraform command...
Running before applying terraform changes...
[terraform apply ...]
```
