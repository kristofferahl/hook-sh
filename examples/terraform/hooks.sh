#!/usr/bin/env bash

hook_pre_terraform_apply() {
  echo 'Doing stuff before applying changes...'
}

hook_post_terraform_destroy() {
  echo 'Doing stuff after destroy...'
}
