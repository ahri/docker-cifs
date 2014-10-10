#!/bin/bash

set -ue

err()
{
    format="$1"
    shift
    printf "$format\n" "$@" 1>&2
    exit 1
}

if [[ $# -lt 3 ]]; then
    err "USAGE: $(basename "$0") WORKGROUP NETBIOS_NAME PATH:SHARE_NAME:MODE [PATH:SHARE_NAME:MODE]"
fi

workgroup="$1"
netbios_name="$2"
shift 2

cat <<EOF > /etc/samba/smb.conf
workgroup = $workgroup
netbios name = $netbios_name
dns proxy = no
syslog only = yes
server role = standalone server
security = share
guest account = nobody
map to guest = bad user
EOF

while [[ $# -gt 0 ]]; do
    split=(${1//:/ })
    path="${split[0]}"
    sharename="${split[1]}"
    mode="${split[2]}"
    shift

    if [[ ! -d $path ]]; then
        err "ERROR: $path is not a directory"
    fi

    case $mode in
    r)
        read_only="yes"
        ;;
    rw)
        read_only="no"
        ;;
    *)
        err "ERROR: $mode is not a supported mode; r/rw"
        ;;
    esac

    cat <<EOF >> /etc/samba/smb.conf

[$sharename]
   browseable = yes
   guest ok = yes
   create mask = 0644
   directory mask = 0775

   path = $path
   read only = $read_only
EOF
done

/sbin/my_init
