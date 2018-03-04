#!/bin/sh

set -ue

if [ $# -lt 4 ]; then
	cat <<EOF 1>&2
Supply: workgroup hostname user:group dir:sharename:perm [dir2:sharename2:perm2...]

    where user:group is the user and group you'd like Samba to use when reading/writing files
    and dir:sharename:perm is a triple of:
        1. the host directory you'd like to share
        2. the name of the share to publish
        3. the permissions for users of the share; either r or rw for read and read-write, respectively
EOF
	exit 1
fi

workgroup="$1"
hostname="$2"
user_group="$3"
shift 3

username="`echo "$user_group" | cut -d':' -f1`"
groupname="`echo "$user_group" | cut -d':' -f2`"
uid="`id -u "$username"`"
gid="`id -g "$groupname"`"

i=0
volumes=""
triples=""
while [ $# -gt 0 ]; do
	triple="$1"
	host_dir="`echo "$triple" | cut -d':' -f1`"
	share="`echo "$triple" | cut -d':' -f2`"
	perms="`echo "$triple" | cut -d':' -f3`"

	container_dir="/tmp/cifs$i"
	volumes="$volumes -v $host_dir:$container_dir"
	triples="$triples $container_dir:$share:$perms"
	i=`expr '$i + 1'`
	shift
done

docker ps | awk '/ahri\/cifs/ { system("docker stop " $1); system("docker rm -vf " $1); }'
docker run -p 139:139 -p 445:445 \
      $volumes \
      ahri/cifs \
      $uid $gid \
      "$workgroup" "$hostname" \
      $triples
