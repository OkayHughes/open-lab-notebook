---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Login
  parent: LeatGrakes
layout: layouts/post.njk
---
How to log in:

Obtain a `user_name.ovpn` file from okay. I'll also give you your password.
* Obtain the OTP seed code/QR code and and set up an authenticator like at [this link](https://docs.opnsense.org/manual/how-tos/two_factor.html).
* Obtain an OpenVPN client e.g. [OpenVPN Connect](https://openvpn.net/vpn-client/)
* Activate the OpenVPN session by logging in using `[6 digit OTP]YOUR_PASSWORD` as the password.
* Tryin pinging `69.43.2.0.12` or `miganich.leatgrakes`. This is the login node which has 32 Haswell cores and cores and ~256Gb of memory.
* Your login name should be the same as your vpn login, same with password. You can SSH in. 

If the server is off for some reason, then install `ipmitool`