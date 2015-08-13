#!/bin/bash

# Update the box
apt-get -y update >/dev/null

# Tweak sshd to prevent DNS resolution (speed up logins)
SSHD_CONF=/etc/ssh/sshd_config
sed -i '/UseDNS yes/,${s//UseDNS no/;b};$q1' $SSHD_CONF \
	|| grep -q 'UseDNS no' $SSHD_CONF \
	|| echo 'UseDNS no' >> $SSHD_CONF
sed -i '/GSSAPIAuthentication yes/,${s//GSSAPIAuthentication no/;b};$q1' $SSHD_CONF \
	|| grep -q 'GSSAPIAuthentication no' $SSHD_CONF \
	|| echo 'GSSAPIAuthentication no' >> $SSHD_CONF

# Set up sudo
grep -q 'secure_path' /etc/sudoers \
	|| sed -i -e '/Defaults\s\+env_reset/a Defaults\tsecure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' /etc/sudoers
sed -i -e 's/^%sudo.*/%sudo ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub
