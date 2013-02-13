#!/bin/bash
#
# requires:
#   bash
#

## include files

. ${BASH_SOURCE[0]%/*}/helper_shunit2.sh

## variables

declare namespace=ssh_key_pair
declare ssh_keypair_path=${BASH_SOURCE[0]%/*}/keypair.$$

declare ssh_key_pair_uuid
declare public_key=${ssh_keypair_path}.pub

## functions

function oneTimeSetUp() {
  ssh-keygen -N "" -f ${ssh_keypair_path} -C shunit2.$$ >/dev/null
}

function oneTimeTearDown() {
  rm -f ${ssh_keypair_path}*
}

###

function test_create_ssh_key_pair() {
  ssh_key_pair_uuid=$(run_cmd ${namespace} create | hash_value id)
  assertEquals $? 0
}

function test_show_ssh_key_pair() {
  run_cmd ${namespace} show ${ssh_key_pair_uuid} >/dev/null
  assertEquals $? 0
}

function test_update_ssh_key_pair() {
  run_cmd ${namespace} update ${ssh_key_pair_uuid} >/dev/null
  assertEquals $? 0
}

function test_destroy_ssh_key_pair() {
  run_cmd ${namespace} destroy ${ssh_key_pair_uuid} >/dev/null
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
