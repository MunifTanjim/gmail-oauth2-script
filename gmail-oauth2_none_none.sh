#!/usr/bin/env bash

set -euo pipefail

echo_err() {
  >&2 echo "$@"
}

assert_value() {
  if [ -z "${!1}" ]; then
    echo_err "${2}"
    exit 1
  fi
}

command="${1}"
shift 1

args=""

client_id=""
client_secret=""
refresh_token=""

while (( "$#" )); do
  case "$1" in
    --client-id)
      client_id="${2}"
      shift 2
      ;;
    --client-secret)
      client_secret="${2}"
      shift 2
      ;;
    --refresh-token)
      refresh_token="${2}"
      shift 2
      ;;
    *)
      args="${args} ${1}"
      shift 1
      ;;
  esac
done

eval set -- "${args}"

get_refresh_token() {
  assert_value "client_id" "missing: client_id"
  assert_value "client_secret" "missing: client_secret"

  local -r scope="https://mail.google.com/"
  local -r redirect_uri="http://127.0.0.1"
  local -r response_type="code"

  echo_err ""
  echo_err "For authorization code, visit this url and follow the instructions:"
  echo_err "  https://accounts.google.com/o/oauth2/v2/auth?client_id=${client_id}&redirect_uri=${redirect_uri}&response_type=${response_type}&scope=${scope}&access_type=offline"
  echo_err ""
  echo_err "Wait till you're redirected to '${redirect_uri}' and copy the 'code' query param from the url."
  echo_err ""
  read -p "Enter authorization code: " authorization_code
  echo_err ""

  local -r grant_type="authorization_code"

  local -r response=$(curl --silent \
    --request POST \
    --data "code=${authorization_code}&client_id=${client_id}&client_secret=${client_secret}&redirect_uri=${redirect_uri}&grant_type=${grant_type}" \
    https://oauth2.googleapis.com/token)

  local -r refresh_token=$(echo "${response}" | jq -r '.refresh_token')

  if [ "${refresh_token}" = "null" ]; then
    echo_err "Could not extract refresh token: "
    echo_err "${response}"
    exit 1
  fi

  printf "${refresh_token}"
}


get_access_token() {
  assert_value "client_id" "missing: client_id"
  assert_value "client_secret" "missing: client_secret"
  assert_value "refresh_token" "missing: refresh_token"

  local -r grant_type="refresh_token"

  local -r access_token_blob=$(curl --silent \
    --request POST \
    --data "client_id=${client_id}&client_secret=${client_secret}&refresh_token=${refresh_token}&grant_type=${grant_type}" \
    "https://oauth2.googleapis.com/token")

  local -r access_token=$(echo "${access_token_blob}" | jq -r '.access_token')

  printf "${access_token}"
}

case "${command}" in
  access_token)
    get_access_token
    ;;
  refresh_token)
    get_refresh_token
    ;;
  *)
    echo_err "unsupported command: ${command}!"
    exit 1
    ;;
esac
