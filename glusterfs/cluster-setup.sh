####Script to create a three node glusterFS cluster 
### Attach the volume using VirtualBOX storage settings

##Create a Physical Volume
pvcreate /dev/sdb
## Create a Volume Group
vgcreate RESEARCH /dev/sdb
## Create Logical Volumes from PV
lvcreate -n res_vol --size 2G RESEARCH
lvcreate -n dev_vol --size 2.5G RESEARCH
## Make mount point dirs
mkdir -p /data/dev_data
mkdir -p /data/res_data
##Make xfs file system on logical volume
mkfs.xfs /dev/RESEARCH/dev_vol
##Mount Logical Volume
mount /dev/RESEARCH/dev_vol /data/dev_data/
##Make xfs file system on logical volume
mkfs.xfs /dev/RESEARCH/res_vol
##Mount Logical Volume
mount /dev/RESEARCH/res_vol /data/res_data/
##Update fstab
echo "/dev/RESEARCH/dev_vol /data/res_data xfs default 0 0" >> /etc/fstab
#Make GlusterFS mountpoint brick
mkdir -p /data/res_data/brick
mkdir -p /data/dev_data/brick
#Add peers to gluster cluster
gluster peer probe k8-node1
gluster peer probe k8-node2
#Create gluster volume 
gluster volume create gv0 replica 3 k8-node1:/data/dev_data/brick k8-node2:/data/dev_data/brick k8-node3:/data/dev_data/brick
