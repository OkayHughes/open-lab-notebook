---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: setting up raid
  parent: LeatGrakes
layout: layouts/post.njk
---

## setting up raid


```
make_part=true
install_mdadm=true
make_fs_and_mount=true
if [ "$make_part" = true ]
then
for i in sda sdb sdc
do
sudo parted --script /dev/$i "mklabel gpt"
sudo parted --script /dev/$i "mkpart primary ext4 0% 100%"
sudo parted --script /dev/$i "set 1 raid on"
sudo parted --script /dev/$i "print"

done

fi
if [ "$install_mdadm" = true ]
then
sudo dnf install mdadm -y
sudo mdadm --create /dev/md0 --level=raid0 --raid-devices=3 /dev/sd[abc]
sudo mdadm --detail /dev/md0

fi

if [ "$make_fs_and_mount" = true ]
then

sudo mkfs.ext4 /dev/md0
sudo mkdir /data
sudo mount /dev/md0 /data
sudo df -hT -P /data
echo "Add to fstab:"
echo "/dev/md0 /data ext4 defaults 0 0"
echo "Add to /etc/mdadm.conf"
sudo mdadm --detail --scan

fi
```
