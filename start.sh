#!/bin/sh
ETC_EXPORTS_PATH=/etc/exports
EXPORT_OPTIONS="*(rw,sync,no_subtree_check,insecure,no_root_squash)"

# If env SHARED_DIRECTORY is not set then exit
if [ -z "${SHARED_DIRECTORY}" ]; then
    echo "SHARED_DIRECTORY is not set. Exiting."
    exit 1
fi

# Removing /etc/exports
rm -f $ETC_EXPORTS_PATH
echo "Removing $ETC_EXPORTS_PATH"

# Generate /etc/exports file
echo "Generating exports..."
env | grep 'SHARED_DIRECTORY' | while read line
do
    # Split the line into name and value
    name=$(echo $line | cut -d= -f1)
    value=$(echo $line | cut -d= -f2-)

    mkdir -p $value

    echo "$value $EXPORT_OPTIONS" >> $ETC_EXPORTS_PATH
done
echo "Generating completed!"
echo "Display $ETC_EXPORTS_PATH"
cat $ETC_EXPORTS_PATH

openrc

touch /run/openrc/softlevel

rc-update add rpcbind
rc-update add nfs

mount -t nfsd nfsd /proc/fs/nfsd

rc-service nfs start
rc-service nfs status

rpcinfo

exportfs -rav
 
showmount -a

while true;
do
    echo ""
    echo "Service status"
    rc-status
    echo "Mounts"
    showmount -a
    sleep 10
done