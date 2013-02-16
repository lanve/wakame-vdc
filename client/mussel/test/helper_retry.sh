# -*-Shell-script-*-
#
# requires:
#   bash
#

function retry_until() {
  local blk="$@"

  local wait_sec=120
  local tries=0
  local start_at=$(date +%s)

  while :; do
    eval "${blk}" && {
      break
    } || {
      sleep 3
    }

    tries=$((${tries} + 1))
    if [[ "$(($(date +%s) - ${start_at}))" -gt "${wait_sec}" ]]; then
      echo "Retry Failure: Exceed ${wait_sec} sec: Retried ${tries} times" >&2
      return 1
    fi
    echo [$(date +%FT%X) "#$$"] time:${tries} "eval:${blk}"
  done
}

function check_port() {
  local ipaddr=$1 protocol=$2 port=$3

  local nc_opts="-w 1"
  case ${protocol} in
  tcp) ;;
  udp) nc_opts="${nc_opts} -u";;
    *) ;;
  esac

  echo | nc ${nc_opts} ${ipaddr} ${port} >/dev/null
}

function check_network_connection() {
  local ipaddr=$1

  ping -c 1 -W 3 ${ipaddr}
}

function wait_for_network_to_be_ready() {
  local ipaddr=$1

  retry_until "check_network_connection ${ipaddr}"
}

function wait_for_port_to_be_ready() {
  local ipaddr=$1 protocol=$2 port=$3

  retry_until "check_port ${ipaddr} ${protocol} ${port}"
}
