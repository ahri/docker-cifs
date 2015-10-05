#!/bin/sh

set -ue

smbconf_location="/smb.conf"

err()
{
    format="$1"
    shift
    printf "$format\n" "$@" 1>&2
    exit 1
}

if [ $# -lt 5 ]; then
    err "USAGE: `basename "$0"` UID GID WORKGROUP NETBIOS_NAME PATH:SHARE_NAME:MODE [PATH:SHARE_NAME:MODE]"
fi

uid="$1"
gid="$2"
workgroup="$3"
netbios_name="$4"
shift 4

if ! echo "$uid" | grep -Eq '^[0-9]+$'; then
	err "ERROR: uid must be one or more digits"
fi

if ! echo "$gid" | grep -Eq '^[0-9]+$'; then
	err "ERROR: gid must be one or more digits"
fi

echo "smbuser:x:$uid:$gid:Samba User:/:/sbin/nologin" >> /etc/passwd
echo "smbgroup:x:$gid:" >> /etc/group

echo "All files will be accessed/written by uid $uid, gid $gid"
echo "Identity: [$workgroup] $netbios_name"

cat <<EOF > "$smbconf_location"
workgroup = $workgroup
netbios name = $netbios_name
dns proxy = no
syslog only = yes
server role = standalone server
security = user
guest account = nobody
map to guest = bad user
EOF

while [ $# -gt 0 ]; do
    path="`echo "$1" | sed 's/:.*//'`"
    sharename="`echo "$1" | sed 's/[^:]*://;s/:.*//'`"
    mode="`echo "$1" | sed 's/.*://'`"
    shift

    if [ ! -d $path ]; then
        err "ERROR: $path is not a directory"
    fi

    case $mode in
    r)
        read_only="yes"
	echo "Serving $path as $sharename, read-only"
        ;;
    rw)
        read_only="no"
	echo "Serving $path as $sharename, read-write"
        ;;
    *)
        err "ERROR: $mode is not a supported mode; r/rw"
        ;;
    esac

    cat <<EOF >> "$smbconf_location"

[$sharename]
   browseable = yes
   guest ok = yes
   create mask = 0644
   directory mask = 0775

   path = $path
   read only = $read_only

   force user = smbuser
   force group = smbgroup
EOF
done

smbd -s "$smbconf_location" -F -d 1 &
nmbd -s "$smbconf_location" -F -d 1 &

wait
