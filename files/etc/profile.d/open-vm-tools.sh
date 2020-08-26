# Mount vmhgfs now a userspace program
# /dev/fuse needs to be writable to user
# /mnt/hgfs-* needs to be a directory and 777

if [ vmware-checkvm ]; then
	for a in $(vmware-hgfsclient); do
		vmhgfsmntpt=/mnt/hgfs
		if grep -q "$vmhgfsmntpt/$a" /etc/mtab; then
			sudo umount -f -l "$vmhgfsmntpt/$a"
		fi
		if [ ! -d "$vmhgfsmntpt" ]; then
			sudo mkdir -m 777 -p "$vmhgfsmntpt"
		fi

		if [ ! -d "$vmhgfsmntpt/$a" ]; then
			vmhgfs-fuse -o allow_other .host:/"$a" "$vmhgfsmntpt/$a"
		fi
	done
fi
