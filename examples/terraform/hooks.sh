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
