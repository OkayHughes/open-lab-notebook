---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: setting up nfs
  parent: LeatGrakes
layout: layouts/post.njk
---

## setting up nfs

Xeon Phi nodes:
```
sudo yum install nfs-utils rpcbind
sudo systemctl enable nfs-server
sudo systemctl enable rpcbind
sudo systemctl start rpcbind
sudo systemctl start nfs-server
```

Miganich node:
```
sudo yum install nfs-utils rpcbind
sudo systemctl enable nfs-server
sudo systemctl enable rpcbind
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo firewall-cmd --permanent --add-port=2049/tcp
sudo firewall-cmd --permanent --add-port=2049/udp
sudo firewall-cmd --reload
```

